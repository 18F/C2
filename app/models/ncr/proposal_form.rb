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
        flow: 'linear',
        name: self.description
      )
      if cart.save
        self.set_props_on(cart)
        self.approver_emails.each do |email|
          cart.add_approver(email)
        end
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
        self.approver_emails.each do |email|
          cart.add_approver(email)
        end
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
        rwa_number: self.rwa_number,
        office: self.office
      )
      cart.set_requester(self.requester)
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
