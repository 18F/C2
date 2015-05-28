require 'csv'

module Ncr
  EXPENSE_TYPES = %w(BA61 BA80)

  BUILDING_NUMBERS = YAML.load_file("#{Rails.root}/config/data/ncr/building_numbers.yml")
  org_code_rows = CSV.read("#{Rails.root}/config/data/ncr/org_codes_2015-05-18.csv", headers: true)
  # TODO reference by `organization_cd` rather than storing the whole thing
  ORG_CODES = org_code_rows.map{|r| "#{r['organization_cd']} #{r['organization_nm']}" }

  class WorkOrder < Proposal
    include ObservableModel

    typed_store :client_fields, coder: ClientFieldsCoder do |f|
      f.decimal :amount
      f.string :expense_type
      f.string :vendor
      f.boolean :not_to_exceed, default: false
      f.string :building_number
      f.boolean :emergency, default: false
      f.string :rwa_number
      f.string :org_code
      f.string :code
      f.string :project_title
      f.string :description
    end

    # @TODO: use integer number of cents to avoid floating point issues
    validates :amount, numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 3000
    }
    validates :expense_type, inclusion: {in: EXPENSE_TYPES}, presence: true
    validates :vendor, presence: true
    validates :building_number, presence: true
    validates :rwa_number, format: {
      with: /[a-zA-Z][0-9]{7}/,
      message: "one letter followed by 7 numbers"
    }, allow_blank: true


    def set_defaults
      self.flow ||= 'linear'
      super
    end

    # A requester can change his/her approving official
    def update_approver(approver_email)
      first_approval = self.approvals.first
      if first_approval.user_email_address != approver_email
        first_approval.destroy
        replacement = self.add_approver(approver_email)
        replacement.move_to_top
      end
    end

    def add_approvals(approver_email)
      emails = [approver_email] + self.system_approvers
      if self.emergency
        emails.each {|email| self.add_observer(email) }
        # skip state machine
        self.update_attribute(:status, 'approved')
      else
        emails.each {|email| self.add_approver(email) }
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
      attributes.map{|key| [WorkOrder.human_attribute_name(key), self.client_fields[key.to_s]]}
    end

    def client
      "ncr"
    end

    def public_identifier
      "FY" + self.fiscal_year.to_s.rjust(2, "0") + "-#{self.id}"
    end

    def total_price
      self.amount || 0.0
    end

    def name
      self.project_title
    end

    protected

    def fiscal_year
      year = self.created_at.year
      if self.created_at.month >= 10
        year += 1
      end
      year % 100   # convert to two-digit
    end

    def system_approvers
      if self.expense_type == 'BA61'
        [
          ENV["NCR_BA61_TIER1_BUDGET_MAILBOX"] || 'communicart.budget.approver@gmail.com',
          ENV["NCR_BA61_TIER2_BUDGET_MAILBOX"] || 'communicart.ofm.approver@gmail.com'
        ]
      else
        [ENV["NCR_BA80_BUDGET_MAILBOX"] || 'communicart.budget.approver@gmail.com']
      end
    end

  end
end
