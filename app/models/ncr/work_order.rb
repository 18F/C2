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
    # In practice, each work order only has one proposal
    has_many :proposals, as: :client_data
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

    def set_defaults
      self.not_to_exceed ||= false
      self.emergency ||= false
    end

    # @todo - this is an awkward dance due to the lingering Cart model. Remove
    # that dependence
    def create_cart(approver_email, description, requester)
      cart = Cart.create(
        name: description,
        proposal_attributes: {flow: 'linear', client_data: self}
      )
      cart.set_requester(requester)
      self.add_approvals_on(cart, approver_email)
      Dispatcher.deliver_new_cart_emails(cart)
      cart
    end
    def update_cart(approver_email, description, cart)
      cart.name = description
      cart.approver_approvals.destroy_all
      self.add_approvals_on(cart, approver_email)
      cart.restart!
      cart
    end

    def system_approvers
      emails = [ENV['NCR_BUDGET_APPROVER_EMAIL'] ||
                'communicart.budget.approver@gmail.com']
      if self.expense_type == 'BA61'
        emails << (ENV['NCR_FINANCE_APPROVER_EMAIL'] ||
                   'communicart.ofm.approver@gmail.com')
      else
        emails
      end
    end

    def add_approvals_on(cart, approver_email)
      emails = [approver_email] + self.system_approvers
      if self.emergency
        emails.each {|email| cart.add_observer(email) }
        # skip state machine
        cart.proposal.update_attribute(:status, 'approved')
      else
        emails.each {|email| cart.add_approver(email) }
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
        fields + [:rwa_number]
      end
    end

    # Methods for Client Data interface
    def fields_for_display
      attributes = Ncr::WorkOrder.relevant_fields(self.expense_type)
      attributes.map{|key| [WorkOrder.human_attribute_name(key), self[key]]}
    end
    def client
      "ncr"
    end
    # @todo - this is pretty ugly
    def public_identifier
      self.proposals[0].cart.id
    end
    def total_price
      self.amount or 0.0
    end
  end
end

