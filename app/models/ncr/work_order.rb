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
    validates :office, presence: true
    # TODO validates :proposal, presence: true

    def set_defaults
      self.not_to_exceed ||= false
      self.emergency ||= false
    end

    # @todo - this is an awkward dance due to the lingering Cart model. Remove
    # that dependence
    def init_and_save_cart(approver_email, description, requester)
      cart = Cart.create(
        name: description,
        proposal_attributes: {flow: 'linear', client_data: self}
      )
      cart.set_requester(requester)
      self.add_approvals(approver_email)
      Dispatcher.deliver_new_cart_emails(cart)
      cart
    end

    def update_cart(approver_email, description, cart)
      cart.name = description
      cart.proposal.approvals.destroy_all
      self.add_approvals(approver_email)
      cart.restart!
      cart
    end

    def add_approvals(approver_email)
      emails = [approver_email] + self.system_approvers
      if self.emergency
        emails.each {|email| self.cart.add_observer(email) }
        # skip state machine
        self.proposal.update_attribute(:status, 'approved')
      else
        emails.each {|email| self.cart.add_approver(email) }
      end
    end

    # Ignore values in certain fields if they aren't relevant. May want to
    # split these into different models
    def self.relevant_fields(expense_type)
      fields = [:amount, :expense_type, :vendor, :not_to_exceed,
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

    # @todo - this is pretty ugly
    def public_identifier
      self.cart.id
    end

    def total_price
      self.amount || 0.0
    end

    def name
      self.cart.try(:name)
    end

    protected
    def budget_approver
      ENV['NCR_BUDGET_APPROVER_EMAIL'] || 'communicart.budget.approver@gmail.com'
    end

    def finance_approver
      ENV['NCR_FINANCE_APPROVER_EMAIL'] || 'communicart.ofm.approver@gmail.com'
    end

    def system_approvers
      emails = [self.budget_approver]
      if self.expense_type == 'BA61'
        emails << self.finance_approver
      end
      emails
    end

  end
end
