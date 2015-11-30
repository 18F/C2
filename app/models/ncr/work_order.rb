require 'csv'

module Ncr
  # Make sure all table names use 'ncr_XXX'
  def self.table_name_prefix
    'ncr_'
  end

  EXPENSE_TYPES = %w(BA60 BA61 BA80)
  BUILDING_NUMBERS = YAML.load_file("#{Rails.root}/config/data/ncr/building_numbers.yml")

  class WorkOrder < ActiveRecord::Base
    # must define before include PurchaseCardMixin
    def self.purchase_amount_column_name
      :amount
    end

    include ValueHelper
    include ProposalDelegate
    include PurchaseCardMixin

    attr_accessor :approving_official_email
    # This is a hack to be able to attribute changes to the correct user. This attribute needs to be set explicitly, then the update comment will use them as the "commenter". Defaults to the requester.
    attr_accessor :modifier

    after_initialize :set_defaults

    validates :approving_official_email, presence: true
    validates_email_format_of :approving_official_email
    validates :amount, presence: true
    validates :cl_number, format: {
      with: /\ACL\d{7}\z/,
      message: "must start with 'CL', followed by seven numbers"
    }, allow_blank: true
    validates :expense_type, inclusion: {in: EXPENSE_TYPES}, presence: true
    validates :function_code, format: {
      with: /\APG[A-Z0-9]{3}\z/,
      message: "must start with 'PG', followed by three letters or numbers"
    }, allow_blank: true
    validates :project_title, presence: true
    validates :vendor, presence: true
    validates :building_number, presence: true, if: :not_ba60?
    validates :rwa_number, presence: true, if: :ba80?
    validates :rwa_number, format: {
      with: /\A[a-zA-Z][0-9]{7}\z/,
      message: "must be one letter followed by 7 numbers"
    }, allow_blank: true
    validates :soc_code, format: {
      with: /\A[A-Z0-9]{3}\z/,
      message: "must be three letters or numbers"
    }, allow_blank: true

    FISCAL_YEAR_START_MONTH = 10 # 1-based
    scope :for_fiscal_year, lambda { |year|
      start_time = Time.zone.local(year - 1, FISCAL_YEAR_START_MONTH, 1)
      end_time = start_time + 1.year
      where(created_at: start_time...end_time)
    }

    def self.all_system_approver_emails
      [
        self.ba61_tier1_budget_mailbox,
        self.ba61_tier2_budget_mailbox,
        self.ba80_budget_mailbox,
        self.ool_ba80_budget_mailbox,
      ]
    end

    def self.ba61_tier1_budget_mailbox
      self.approver_with_role("BA61_tier1_budget_approver")
    end

    def self.ba61_tier2_budget_mailbox
      self.approver_with_role("BA61_tier2_budget_approver")
    end

    def self.ba80_budget_mailbox
      self.approver_with_role("BA80_budget_approver")
    end

    def self.ool_ba80_budget_mailbox
      self.approver_with_role("OOL_BA80_budget_approver")
    end

    def self.approver_with_role(role_name)
      users = User.with_role(role_name).where(client_slug: "ncr")

      if users.empty?
        fail "Missing User with role #{role_name} -- did you run rake db:migrate and rake db:seed?"
      end

      users.first.email_address
    end

    def self.relevant_fields(expense_type)
      fields = self.default_fields

      if expense_type == "BA61"
        fields << :emergency
      elsif expense_type == "BA80"
        fields += [:rwa_number, :code]
      end

      fields
    end

    def self.default_fields
      fields = self.column_names.map(&:to_sym) + [:approving_official_email]
      fields - [:emergency, :rwa_number, :code, :created_at, :updated_at, :id]
    end

    def set_defaults
      # not sure why the latter condition is necessary...was getting some weird errors from the tests without it. -AF 10/5/2015
      if !self.approving_official_email && self.approvers.any?
        self.approving_official_email = self.approvers.first.try(:email_address)
      end
    end

    def approver_email_frozen?
      approval = self.individual_steps.first
      approval && !approval.actionable?
    end

    def approver_changed?
      self.approving_official && self.approving_official.email_address != approving_official_email
    end

    def requires_approval?
      !self.emergency
    end

    def setup_approvals_and_observers
      manager = ApprovalManager.new(self)
      manager.setup_approvals_and_observers
    end

    def approving_official
      approvers.first
    end

    def current_approver
      if pending?
        currently_awaiting_approvers.first
      elsif approving_official
        approving_official
      elsif emergency and approvers.empty?
        nil
      else
        User.for_email(system_approver_emails.first)
      end
    end

    def final_approver
      if !emergency and approvers.any?
        approvers.last
      end
    end

    def budget_approvals
      self.individual_steps.offset(1)
    end

    def budget_approvers
      self.approvers.merge(self.budget_approvals)
    end

    def editable?
      true
    end

    # Methods for Client Data interface
    def fields_for_display
      attributes = self.class.relevant_fields(expense_type)
      attributes.map{|key| [WorkOrder.human_attribute_name(key), self[key]]}
    end

    # will return nil if the `org_code` is blank or not present in Organization list
    def organization
      # TODO reference by `code` rather than storing the whole thing
      code = (org_code || '').split(' ', 2)[0]
      Ncr::Organization.find(code)
    end

    def ba80?
      self.expense_type == 'BA80'
    end

    def not_ba60?
      expense_type != "BA60"
    end

    def total_price
      self.amount || 0.0
    end

    # may be replaced with paper-trail or similar at some point
    def version
      self.updated_at.to_i
    end

    def system_approver_emails
      manager = ApprovalManager.new(self)
      manager.system_approver_emails
    end

    def org_id
      self.organization.try(:code)
    end

    def building_id
      regex = /\A(\w{8}) .*\z/
      if self.building_number && regex.match(self.building_number)
        regex.match(self.building_number)[1]
      else
        self.building_number
      end
    end

    def as_json
      super.merge(org_id: self.org_id, building_id: self.building_id)
    end

    def name
      project_title
    end

    def public_identifier
      "FY" + fiscal_year.to_s.rjust(2, "0") + "-#{proposal.id}"
    end

    def fiscal_year
      year = self.created_at.nil? ? Time.zone.now.year : self.created_at.year
      month = self.created_at.nil? ? Time.zone.now.month : self.created_at.month
      if month >= 10
        year += 1
      end
      year % 100   # convert to two-digit
    end

    def restart_budget_approvals
      self.budget_approvals.each(&:restart!)
      self.proposal.reset_status
      self.proposal.root_step.initialize!
    end
  end
end
