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
    validates :building_number, presence: true
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

    # Ignore values in certain fields if they aren't relevant. May want to
    # split these into different models
    def self.relevant_fields(expense_type)
      fields = [:description, :amount, :expense_type, :vendor, :not_to_exceed,
                :building_number, :org_code, :direct_pay, :cl_number, :function_code, :soc_code]
      case expense_type
      when "BA61"
        fields << :emergency
      when "BA80"
        fields.concat([:rwa_number, :code])
      end

      fields
    end

    def set_defaults
      # not sure why the latter condition is necessary...was getting some weird errors from the tests without it. -AF 10/5/2015
      if !self.approving_official_email && self.approvers.any?
        self.approving_official_email = self.approvers.first.try(:email_address)
      end
    end

    def approver_email_frozen?
      approval = self.individual_approvals.first
      approval && !approval.actionable?
    end

    def approver_changed?
      self.approving_official && self.approving_official.email_address != approving_official_email
    end

    # Check the approvers, accounting for frozen approving official
    def approvers_emails
      emails = system_approver_emails

      if approver_email_frozen?
        emails.unshift(approving_official.email_address)
      else
        emails.unshift(approving_official_email)
      end

      emails
    end

    def setup_approvals_and_observers
      emails = approvers_emails
      if emergency
        emails.each{|e| add_observer(e)}
        # skip state machine
        proposal.update(status: 'approved')
      else
        original_approvers = proposal.individual_approvals.non_pending.map(&:user)
        force_approvers(emails)
        notify_removed_approvers(original_approvers)
      end
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

    def email_approvers
      Dispatcher.on_proposal_update(self.proposal, self.modifier)
    end

    def relevant_fields
      Ncr::WorkOrder.relevant_fields(self.expense_type)
    end

    # Methods for Client Data interface
    def fields_for_display
      attributes = self.relevant_fields
      attributes.map{|key| [WorkOrder.human_attribute_name(key), self[key]]}
    end

    # will return nil if the `org_code` is blank or not present in Organization list
    def organization
      # TODO reference by `code` rather than storing the whole thing
      code = (self.org_code || '').split(' ', 2)[0]
      Ncr::Organization.find(code)
    end

    def ba80?
      self.expense_type == 'BA80'
    end

    def total_price
      self.amount || 0.0
    end

    # may be replaced with paper-trail or similar at some point
    def version
      self.updated_at.to_i
    end

    def name
      self.project_title
    end

    def system_approver_emails
      results = []
      if %w(BA60 BA61).include?(expense_type)
        unless organization.try(:whsc?)
          results << self.class.ba61_tier1_budget_mailbox
        end
        results << self.class.ba61_tier2_budget_mailbox
      else # BA80
        if organization.try(:ool?)
          results << self.class.ool_ba80_budget_mailbox
        else
          results << self.class.ba80_budget_mailbox
        end
      end

      results
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

    protected

    # Generally shouldn't be called directly as it doesn't account for
    # emergencies, or notify removed approvers
    def force_approvers(emails)
      individuals = emails.map do |email|
        user = User.for_email(email)
        user.update!(client_slug: 'ncr')
        # Reuse existing approvals, if present
        self.proposal.existing_approval_for(user) || Approvals::Individual.new(user: user)
      end
      self.proposal.root_approval = Approvals::Serial.new(child_approvals: individuals)
    end

    def notify_removed_approvers(original_approvers)
      current_approvers = self.proposal.individual_approvals.non_pending.map(&:user)
      removed_approvers_to_notify = original_approvers - current_approvers
      Dispatcher.on_approver_removal(self.proposal, removed_approvers_to_notify)
    end
  end
end
