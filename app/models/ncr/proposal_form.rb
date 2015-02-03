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
      'P1100000 Prior Year Activities',
      'P1110001 Asst Regional Admin & Staff',
      'P1110003 Planning Staff',
      'P1110009 Disaster/Emg Support FEMA',
      'P1110050 Mgmt Support Staff',
      'P1110101 Transfer Projects',
      'P112HOTD HOTD',
      'P1120001 RWA Billing',
      'P1120400 Safety Environment Mgmt Div',
      'P1120401 Director and Staff',
      'P1120WTC World Trade Center',
      'P1120X00 Buildings Mgmt Interns',
      'P1121101 Potomac Services Division',
      'P1121200 Service Delivery Support',
      'P1121201 Service Delivery Support',
      'P1121202 Maintenance and Energy',
      'P1121203 Resource Management',
      'P1121204 Concessions & Spec Serv',
      'P1121205 Safety & Environment Mgmt',
      'P1121206 Service Contracts',
      'P1121207 Engineering Services',
      'P1121208 Project Development',
      'P1121209 Security Management',
      'P1121210 Bldg Delegations Mgmt',
      'P1122021 White House District',
      'P1123000 South District',
      'P1123001 Special Services Division',
      'P1124000 East District',
      'P1124001 Triangle Services Division',
      'P1125001 Md No Ser Delivery Team',
      'P1125052 Columbia Pk Field ofc VA',
      'P1125053 Pentagon Field Ofc VA',
      'P1125054 Mcclean Field Ofc VA',
      'P1125057 Springfield Field Ofc',
      'P1125059 Arlington Awg',
      'P1126001 Metropolitan Services Di',
      'P1126069 West Awg',
      'P1127001 DC Services Division',
      'P1128001 PBS - Miscellaneous',
      'P1129001 PBS - Miscellaneous',
      'P1130001 Fed Prt & Safety Div Dir Staff',
      'P1130100 Threat Management Branch',
      'P1130200 Support Branch',
      'P1130300 Police Bureau',
      'P1130400 Training Staff',
      'P1130500 Support Staff',
      'P1130600 Security Bureau',
      'P1130WTC World Trade Center',
      'P1138100 Federal Triangle & Central D',
      'P1138200 Eastern District',
      'P1138300 Western District',
      'P1140001 Property Development Div',
      'P1140200 Technical Support Branch',
      'P1140400 Procurement Branch',
      'P1140600 Project Management Branch',
      'P1150001 Director & Staff',
      'P1150002 Portfolio Management',
      'P1150003 Ronald Reagan Staff',
      'P1160001 ARRA',
      'P1170001 Leasing Policy & Performance',
      'P1170003 Program Support Services',
      'P1170100 Space Delivery Team 1',
      'P1170200 Space Delivery Team 2',
      'P1170300 Space Delivery Team 3',
      'P1170400 Space Delivery Team 4',
      'P1170500 Space Delivery Team 5',
      'P1170600 Space Delivery Team 6',
      'P1170900 Space Mgmt & Acqutn Branch',
      'P11B0001 Business Mgmt Div',
      'P11C0001 Director & Staff',
      'P11C0200 Project Execution Branch',
      'P11D0001 Marketing Division',
      'P11D0002 Special Events Staff',
      'P11E0001 Acquisition Executive',
      'P11E0300 A&E Design Branch',
      'P11E0500 Construction Branch B',
      'P11F0001 Financial Management Division',
      'P11J0001 OPDQ',
      'P11IS001 Integrated Solutions - R',
      'P11M0001 Information Technology D',
      'P11NH141 Ofc Workplace Initiative',
      'P11P0001 Presidential Protection',
      'P11R0001 RRB & ITC Staff',
      'P11R0002 International Trade Center',
      'P11T0001 Portfolio Management Div',
      'P11T0002 Portfolio Planning',
      'P11T0003 Asset Management',
      'P11T0004 Portfolio Management Sta',
      'P11X0001 Business Management Division',
      'P11Y0002 Presidential Libraries c',
      'P11Z0001 Procurement Management Division',
      'PGC 11 Recurring Pymts - New Obl Authority (NOA)',
      'PGC 15 Recurring Pymts - Indefinite Authority (IA)',
      'P1171001 Lease Program Management Division',
      'P1172001 Lease Project Management Division',
      'P1173001 Real Estate Administration Division'
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
