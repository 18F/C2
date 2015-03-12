module Ncr
  DATA = YAML.load_file("#{Rails.root}/config/data/ncr.yaml")

  class ProposalForm
    include SimpleFormObject

    EXPENSE_TYPES = %w(BA61 BA80)

    BUILDING_NUMBERS = DATA['BUILDING_NUMBERS']
    OFFICES = DATA['OFFICES']
    attribute :origin, :string
    attribute :amount, :decimal
    attribute :approver_email, :text
    attribute :description, :text
    attribute :expense_type, :text
    attribute :requester, :user
    attribute :vendor, :string
    attribute :not_to_exceed, :boolean
    attribute :building_number, :string
    attribute :emergency, :boolean
    attribute :rwa_number, :string
    attribute :office, :string

    validates :amount, numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 3000
    }
    validates :approver_email, presence: true
    validates :description, presence: true
    validates :expense_type, inclusion: {in: EXPENSE_TYPES}, presence: true
    validates :requester, presence: true
    validates :vendor, presence: true
    validates :building_number, presence: true
    validates :office, presence: true

    def budget_approver_email
      ENV['NCR_BUDGET_APPROVER_EMAIL'] || 'communicart.budget.approver@gmail.com'
    end

    def finance_approver_email
      ENV['NCR_FINANCE_APPROVER_EMAIL'] || 'communicart.ofm.approver@gmail.com'
    end

    def requires_finance_approval?
      self.expense_type == 'BA61'
    end

    def approver_emails
      emails = [self.approver_email, self.budget_approver_email]
      if self.requires_finance_approval?
        emails << self.finance_approver_email
      end

      emails
    end

    def create_cart
      cart = Cart.new(
        name: self.description,
        proposal_attributes: {flow: 'linear'}
      )
      if cart.save
        self.set_props_on(cart)
        self.add_approvals_on(cart)
        Dispatcher.deliver_new_cart_emails(cart)
      end

      cart
    end

    def update_cart(cart)
      cart.name = self.description
      if cart.save
        cart.approver_approvals.destroy_all
        # @todo: do we actually want to clear all properties?
        cart.clear_props!
        self.set_props_on(cart)
        self.add_approvals_on(cart)
        cart.restart!
      end
      cart
    end

    def set_props_on(cart)
      cart.set_props(
        origin: self.origin,
        amount: self.amount,
        expense_type: self.expense_type,
        vendor: self.vendor,
        not_to_exceed: self.not_to_exceed,
        building_number: self.building_number,
        office: self.office
      )
      case self.expense_type
        when 'BA61'
          # Hack to account for SimpleFormObject bugs
          cart.set_props(emergency: self.emergency != false && self.emergency != "0")
        when 'BA80'
          cart.set_props(rwa_number: self.rwa_number)
      end
      cart.set_requester(self.requester)
    end

    def add_approvals_on(cart)
      # Hack to account for SimpleFormObject bugs
      if self.emergency == true || self.emergency == "1"
        self.approver_emails.each do |email|
          cart.add_observer(email)
        end
        # skip state machine
        cart.proposal.update_attribute(:status, 'approved')
      else
        self.approver_emails.each do |email|
          cart.add_approver(email)
        end
      end
    end

    def self.from_cart(cart)
      relevant_properties = self._attributes.map(&:name).map(&:to_s)
      properties = cart.deserialized_properties.select{
        |key, val| relevant_properties.include? key
      }
      form = self.new(properties)
      form.approver_email = cart.ordered_approvals.first.user.email_address
      form.description = cart.name
      form
    end
  end
end
