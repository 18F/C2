require 'csv'

module Ncr
  # Make sure all table names use 'ncr_XXX'
  def self.table_name_prefix
    'ncr_'
  end

  EXPENSE_TYPES = %w(BA60 BA61 BA80)
  BUILDING_NUMBERS = YAML.load_file("#{Rails.root}/config/data/ncr/building_numbers.yml")

  class WorkOrder < ActiveRecord::Base
    include ValueHelper

    has_one :proposal, as: :client_data
    include ProposalDelegate

    # This is a hack to be able to attribute changes to the correct user. This attribute needs to be set explicitly, then the update comment will use them as the "commenter". Defaults to the requester.
    attr_accessor :modifier

    after_initialize :set_defaults
    before_validation :normalize_values
    before_update :record_changes

    # @TODO: use integer number of cents to avoid floating point issues
    validates :amount, numericality: {
      less_than_or_equal_to: 3000,
      message: "must be less than or equal to $3,000"
    }
    validates :amount, numericality: {
      greater_than_or_equal_to: 0,
      message: "must be greater than or equal to $0"
    }
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
      with: /[a-zA-Z][0-9]{7}/,
      message: "must be one letter followed by 7 numbers"
    }, allow_blank: true
    validates :soc_code, format: {
      with: /\A[A-Z0-9]{3}\z/,
      message: "must be three letters or numbers"
    }, allow_blank: true

    def set_defaults
      self.direct_pay ||= false
      self.not_to_exceed ||= false
      self.emergency ||= false
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

    # A requester can change his/her approving official
    def update_approvers(approver_email=nil)
      first_approval = self.approvals.first
      if approver_email && self.approver_changed?(approver_email)
        first_approval.destroy
        replacement = self.add_approver(approver_email)
        replacement.move_to_top
        self.approvals.first.make_actionable!
      end
      # no need to call initialize_approvals as they have already been set up
      current_approvers = self.approvers.map {|a| a[:email_address]}
      #remove approving official
      current_approvers.shift
      if (!self.approvers_match?)
        current_approvers.each do |email|
          self.remove_approver(email)
        end
        system_approvers.each do |email|
          self.add_approver(email)
        end
        approvals = self.approvals
        if(approvals.first.approved?)
          approvals.second.make_actionable!
        end
      end
    end

    def approvers_match?
      current_approvers = self.approvers.map {|a| a[:email_address]}
      if current_approvers.length != system_approvers.length
        return false
      end
      match = true
      system_approvers.each_with_index do |approver, i|
          if approver != current_approvers[i]
            system_approver = User.for_email(approver)
            current_approver = User.for_email(current_approvers[i])
            if !system_approver.delegates_to?(current_approver)
              match = false
              break
            end
          end
      end
      match
    end

    def approver_changed?(approval_email)
      first_approval = self.proposal.approvals.first.user_email_address
      first_approval != approval_email
    end

    def add_approvals(approver_email)
      emails = [approver_email] + self.system_approvers
      if self.emergency
        emails.each {|email| self.add_observer(email) }
        # skip state machine
        self.proposal.update_attribute(:status, 'approved')
      else
        emails.each {|email| self.add_approver(email) }
        self.proposal.initialize_approvals()
      end
    end

    def email_approvers
      Dispatcher.on_proposal_update(self.proposal)
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

    def client
      "ncr"
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

    def system_approvers
      results = []
      if %w(BA60 BA61).include?(self.expense_type)
        unless self.organization.try(:whsc?)
          results << self.class.ba61_tier1_budget_mailbox
        end
        results << self.class.ba61_tier2_budget_mailbox
      else
        results << self.class.ba80_budget_mailbox
      end

      results
    end

    def self.ba61_tier1_budget_mailbox
      ENV['NCR_BA61_TIER1_BUDGET_MAILBOX'] || 'communicart.budget.approver@gmail.com'
    end

    def self.ba61_tier2_budget_mailbox
      ENV['NCR_BA61_TIER2_BUDGET_MAILBOX'] || 'communicart.ofm.approver@gmail.com'
    end

    def self.ba80_budget_mailbox
      ENV['NCR_BA80_BUDGET_MAILBOX'] || 'communicart.budget.approver@gmail.com'
    end

    protected

    # TODO move to Proposal model
    def record_changes
      changed_attributes = self.changed_attributes.except(:updated_at)
      comment_texts = []
      bullet = changed_attributes.length > 1 ? '- ' : ''
      changed_attributes.each do |key, value|
        value = property_to_s(self[key])
        property_name = WorkOrder.human_attribute_name(key)
        comment_texts << WorkOrder.update_comment_format(property_name, value, bullet)
      end

      if !comment_texts.empty?
        if self.approved?
          comment_texts << "_Modified post-approval_"
        end
        self.proposal.comments.create(
          comment_text: comment_texts.join("\n"),
          update_comment: true,
          user: self.modifier || self.requester
        )
      end
    end

    def self.update_comment_format key, value, bullet
      "#{bullet}*#{key}* was changed to #{value}"
    end

    def fiscal_year
      year = self.created_at.nil? ? Time.now.year : self.created_at.year
      month = self.created_at.nil? ? Time.now.month : self.created_at.month
      if month >= 10
        year += 1
      end
      year % 100   # convert to two-digit
    end
  end
end
