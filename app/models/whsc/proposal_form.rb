module Whsc
  class ProposalForm
    include SimpleFormObject

    EXPENSE_TYPES = %w(BA61 BA80)

    attribute :origin, :string
    attribute :amount, :decimal
    attribute :approver_email, :text
    attribute :description, :text
    attribute :expense_type, :text
    attribute :requester, :user
    attribute :vendor, :string
    attribute :not_to_exceed, :boolean
    attribute :building_number, :string
    attribute :RWA_number, :string

    validates :amount, numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 3000
    }
    validates :approver_email, presence: true
    validates :description, presence: true
    validates :expense_type, inclusion: {in: EXPENSE_TYPES}, presence: true
    validates :requester, presence: true
    validates :vendor, presence: true

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
        cart.set_props(
          amount: self.amount,
          expense_type: self.expense_type,
          origin: self.origin,
          vendor: self.vendor,
          not_to_exceed: self.not_to_exceed,
          building_number: self.building_number,
          RWA_number: self.RWA_number
        )
        cart.set_requester(self.requester)

        self.approver_emails.each do |email|
          cart.add_approver(email)
        end
      end

      cart
    end
  end
end
