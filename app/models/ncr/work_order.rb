module Ncr
  # Make sure all table names use 'ncr_XXX'
  def self.table_name_prefix
    'ncr_'
  end

  DATA = YAML.load_file("#{Rails.root}/config/data/ncr.yaml")

  EXPENSE_TYPES = %w(BA61 BA80)

  BUILDING_NUMBERS = DATA['BUILDING_NUMBERS']
  OFFICES = DATA['OFFICES']

  class WorkOrder < ActiveRecord::Base
    include ObservableModel
    # TODO include ProposalDelegate

    has_one :proposal, as: :client_data
    # TODO remove the dependence
    has_one :cart, through: :proposal

    after_initialize :set_defaults

    # @TODO: use integer number of cents to avoid floating point issues
    validates :amount, numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 3000
    }
    validates :expense_type, inclusion: {in: EXPENSE_TYPES}, presence: true
    validates :vendor, presence: true
    validates :building_number, presence: true
    # TODO validates :proposal, presence: true

    def set_defaults
      self.not_to_exceed ||= false
      self.emergency ||= false
    end

    # @todo - this is an awkward dance due to the lingering Cart model. Remove
    # that dependence
    def init_and_save_cart(approver_email, requester)
      cart = Cart.create(
        proposal_attributes: {flow: 'linear', client_data: self}
      )
      cart.set_requester(requester)
      self.add_approvals(approver_email)
      Dispatcher.deliver_new_cart_emails(cart)
      cart
    end

    # A requester can change his/her approving official
    def update_approver(approver_email)
      first_approval = self.proposal.approvals.first
      if first_approval.user_email_address != approver_email
        first_approval.destroy
        replacement = self.proposal.add_approver(approver_email)
        replacement.move_to_top
        Dispatcher.email_approver(replacement)
      end
    end

    def add_approvals(approver_email)
      emails = [approver_email] + self.system_approvers
      if self.emergency
        emails.each {|email| self.proposal.add_observer(email) }
        # skip state machine
        self.proposal.update_attribute(:status, 'approved')
      else
        emails.each {|email| self.proposal.add_approver(email) }
      end
    end

    # Ignore values in certain fields if they aren't relevant. May want to
    # split these into different models
    def self.relevant_fields(expense_type)
      fields = [:description, :amount, :expense_type, :vendor, :not_to_exceed,
                :building_number, :office]
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

    def public_identifier
      "FY" + self.fiscal_year.to_s.rjust(2, "0") + "-#{self.id}"
    end

    def total_price
      self.amount || 0.0
    end

    # may be replaced with paper-trail or similar at some point
    def version
      self.updated_at.to_i
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
