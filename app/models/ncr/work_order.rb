require 'csv'

module Ncr
  # Make sure all table names use 'ncr_XXX'
  def self.table_name_prefix
    'ncr_'
  end

  EXPENSE_TYPES = %w(BA60 BA61 BA80)
  BUILDING_NUMBERS = YAML.load_file("#{Rails.root}/config/data/ncr/building_numbers.yml")

  class WorkOrder < ActiveRecord::Base
      NCR_BA61_TIER1_BUDGET_APPROVER_MAILBOX = ENV['NCR_BA61_TIER1_BUDGET_MAILBOX'] || 'communicart.budget.approver+ba61@gmail.com'
      NCR_BA61_TIER2_BUDGET_APPROVER_MAILBOX = ENV['NCR_BA61_TIER2_BUDGET_MAILBOX'] || 'communicart.ofm.approver@gmail.com'
      NCR_BA80_BUDGET_APPROVER_MAILBOX = ENV['NCR_BA80_BUDGET_MAILBOX'] || 'communicart.budget.approver+ba80@gmail.com'
      OOL_BA80_BUDGET_APPROVER_MAILBOX = ENV['NCR_OOL_BA80_BUDGET_MAILBOX'] || 'communicart.budget.approver+ool_ba80@gmail.com'

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
    before_validation :normalize_values
    before_update :record_changes

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

    def set_defaults
      # not sure why the latter condition is necessary...was getting some weird errors from the tests without it. -AF 10/5/2015
      if !self.approving_official_email && self.approvers.any?
        self.approving_official_email = self.approvers.first.try(:email_address)
      end
    end

    # For budget attributes, converts empty strings to `nil`, so that the request isn't shown as being modified when the fields appear in the edit form.
    def normalize_values
      if self.cl_number.present?
        self.cl_number = self.cl_number.upcase
        self.cl_number.prepend('CL') unless self.cl_number.start_with?('CL')
      else
        self.cl_number = nil
      end

      if self.function_code.present?
        self.function_code.upcase!
        self.function_code.prepend('PG') unless self.function_code.start_with?('PG')
      else
        self.function_code = nil
      end

      if self.soc_code.present?
        self.soc_code.upcase!
      else
        self.soc_code = nil
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
      emails = self.system_approver_emails

      if self.approver_email_frozen?
        emails.unshift(self.approving_official.email_address)
      else
        emails.unshift(self.approving_official_email)
      end
      emails
    end

    def setup_approvals_and_observers
      emails = self.approvers_emails
      if self.emergency
        emails.each{|e| self.add_observer(e)}
        # skip state machine
        self.proposal.update(status: 'approved')
      else
        original_approvers = self.proposal.individual_approvals.non_pending.map(&:user)
        self.force_approvers(emails)
        self.notify_removed_approvers(original_approvers)
      end
    end

    def approving_official
      self.approvers.first
    end

    def current_approver
      if pending?
        currently_awaiting_approvers.first
      elsif approving_official
        approving_official
      elsif emergency and approvers.empty?
        nil
      else
        User.for_email(self.system_approver_emails.first)
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

    # Ignore values in certain fields if they aren't relevant. May want to
    # split these into different models
    def self.relevant_fields(expense_type)
      fields = [:description, :amount, :expense_type, :vendor, :not_to_exceed,
                :building_number, :org_code, :direct_pay, :cl_number, :function_code, :soc_code]
      case expense_type
      when 'BA61'
        fields << :emergency
      when 'BA80'
        fields.concat([:rwa_number, :code])
      end

      fields
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

    def public_identifier
      "FY" + self.fiscal_year.to_s.rjust(2, "0") + "-#{self.proposal.id}"
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
      if %w(BA60 BA61).include?(self.expense_type)
        unless self.organization.try(:whsc?)
          results << self.class.ba61_tier1_budget_mailbox
        end
        results << self.class.ba61_tier2_budget_mailbox
      else # BA80
        if self.organization.try(:ool?)
          results << self.class.ool_ba80_budget_mailbox
        else
          results << self.class.ba80_budget_mailbox
        end
      end

      results
    end

    def self.ba61_tier1_budget_mailbox
      NCR_BA61_TIER1_BUDGET_APPROVER_MAILBOX
    end

    def self.ba61_tier2_budget_mailbox
      NCR_BA61_TIER2_BUDGET_APPROVER_MAILBOX
    end

    def self.ba80_budget_mailbox
      NCR_BA80_BUDGET_APPROVER_MAILBOX
    end

    def self.ool_ba80_budget_mailbox
      OOL_BA80_BUDGET_APPROVER_MAILBOX
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

    def fiscal_year
      year = self.created_at.nil? ? Time.zone.now.year : self.created_at.year
      month = self.created_at.nil? ? Time.zone.now.month : self.created_at.month
      if month >= 10
        year += 1
      end
      year % 100   # convert to two-digit
    end

    protected

    # TODO move to Proposal model
    def record_changes
      changed_attributes = self.changed_attributes.except(:updated_at)
      comment_texts = []
      bullet = changed_attributes.length > 1 ? '- ' : ''
      changed_attributes.each do |key, value|
        former = property_to_s(self.send(key + "_was"))
        value = property_to_s(self[key])
        property_name = WorkOrder.human_attribute_name(key)
        comment_texts << WorkOrder.update_comment_format(property_name, value, bullet, former)
      end

      if !comment_texts.empty?
        if self.approved?
          comment_texts << "_Modified post-approval_"
        end

        proposal.comments.create(
          comment_text: comment_texts.join("\n"),
          update_comment: true,
          user: self.modifier || self.requester
        )
      end
    end

    def self.update_comment_format(key, value, bullet, former=nil)
      if !former || former.empty?
        from = ""
      else
        from = "from #{former} "
      end
      if value.empty?
        to = "*empty*"
      else
        to = value
      end
      "#{bullet}*#{key}* was changed " + from + "to #{to}"
    end

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
