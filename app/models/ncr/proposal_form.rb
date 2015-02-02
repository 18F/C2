module Ncr
  class ProposalForm
    include SimpleFormObject

    EXPENSE_TYPES = %w(BA61 BA80)

    BUILDING_NUMBERS = [
      'DC0017ZZ ,WHITE HOUSE-WEST WING1600 PA AVE. NW',
      'DC0027ZZ ,MAIL FACILITY2701 SOUTH CAPITOL ST.',
      'DC0035ZZ ,DWIGHT D. EISENHOWER EXECUTIVE17TH AND PA AVE. NW',
      'DC0037ZZ ,WHITE HOUSE - EAST WING1600 PA AVE., NW',
      'DC0042ZZ ,PRESIDENTS GUEST HOU1651-53 PA AVE NW',
      'DC0048ZZ ,WINDER600 SEVENTEENTH STREET',
      'DC0078ZZ ,1724 F STREET NW1724 F STREET NW',
      'DC0105ZZ ,NEW EXECUTIVE OFFICE725 17TH STREET NW',
      'Entire Jackson Place Complex',
      'DC0117ZZ ,JACKSON PL COMPLEX708 JACKSON PLACE NW',
      'DC0118ZZ ,JACKSON PL COMPLEX712 JACKSON PL NW',
      'DC0119ZZ ,JACKSON PL COMPLEX716 JACKSON PLACE NW',
      'DC0120ZZ ,JACKSON PL COMPLEX718 JACKSON PL NW',
      'DC0121ZZ ,JACKSON PL COMPLEX722 JACKSON PL NW',
      'DC0122ZZ ,JACKSON PL COMPLEX726 JACKSON PL NW',
      'DC0123ZZ ,JACKSON PL COMPLEX730 JACKSON PL NW',
      'DC0124ZZ ,JACKSON PL COMPLEX734 JACKSON PLACE NW',
      'DC0125ZZ ,JACKSON PL COMPLEX736 JACKSON PLACE NW',
      'DC0126ZZ ,JACKSON PL COMPLEX740 JACKSON PLACE NW',
      'DC0127ZZ ,JACKSON PL COMPLEX744 JACKSON PLACE NW',
      'DC0458ZZ ,REMOTE DELIVERY SITE2701 SOUTH CAPITOL ST.',
      'DC0469ZZ ,VEHICLE MAIN FAC2702 S CAPITOL ST SE',
      'DC0545ZZ ,RDS/VMF GUARDHOUSE2701 S. CAPITOL STREET',
      'Entire WH Complex',
      'Administrative Expense'
    ]
    OFFICES = [
      'Example Office'
    ]
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
        self.approver_emails.each do |email|
          cart.add_approver(email)
        end
      end

      cart
    end
  end
end
