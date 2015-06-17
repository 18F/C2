require 'csv'

module Ncr
  # Make sure all table names use 'ncr_XXX'
  def self.table_name_prefix
    'ncr_'
  end

  EXPENSE_TYPES = %w(BA61 BA80)
  BUILDING_NUMBERS = YAML.load_file("#{Rails.root}/config/data/ncr/building_numbers.yml")

  class WorkOrder < ActiveRecord::Base
    include ObservableModel
    include ValueHelper

    has_one :proposal, as: :client_data
    include ProposalDelegate

    after_initialize :set_defaults
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
    validates :expense_type, inclusion: {in: EXPENSE_TYPES}, presence: true
    validates :project_title, presence: true
    validates :vendor, presence: true
    validates :building_number, presence: true
    validates :rwa_number, format: {
      with: /[a-zA-Z][0-9]{7}/,
      message: "one letter followed by 7 numbers"
    }, allow_blank: true

    def set_defaults
      self.not_to_exceed ||= false
      self.emergency ||= false
    end

    # A requester can change his/her approving official
    def update_approver(approver_email)
      first_approval = self.approvals.first
      if first_approval.user_email_address != approver_email
        first_approval.destroy
        replacement = self.add_approver(approver_email)
        replacement.move_to_top
      end
      # no need to call initialize_approvals as they have already been set up
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

    # Ignore values in certain fields if they aren't relevant. May want to
    # split these into different models
    def self.relevant_fields(expense_type)
      fields = [:description, :amount, :expense_type, :vendor, :not_to_exceed,
                :building_number, :org_code]
      case expense_type
      when "BA61"
        fields + [:emergency]
      when "BA80"
        fields + [:rwa_number, :code]
      end
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

    def org_code_instance
      # TODO reference by `code` rather than storing the whole thing
      code = self.org_code.split(' ', 2)[0]
      Ncr::OrgCode.find(code)
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
      if self.expense_type == 'BA61'
        unless self.org_code_instance.whsc?
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

    def record_changes
      changed_attributes = self.changed_attributes.clone
      changed_attributes.delete(:updated_at)
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
          user_id: self.proposal.requester_id
        )
      end
    end

    def self.update_comment_format key, value, bullet
      "#{bullet}*#{key}* was changed to #{value}"
    end

    def fiscal_year
      year = self.created_at.year
      if self.created_at.month >= 10
        year += 1
      end
      year % 100   # convert to two-digit
    end
  end
end
