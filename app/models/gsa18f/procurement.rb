module Gsa18f
  # Make sure all table names use 'gsa18f_XXX'
  def self.table_name_prefix
    'gsa18f_'
  end

  class Procurement < ActiveRecord::Base
    URGENCY = {
      10 => "I need it yesterday",
      20 => "I'm patient but would like w/in a week",
      30 => "Whenever",
    }

    OFFICES = [
      "DC",
      "Chicago",
      "Dayton",
      "New York",
      "San Francisco",
      "Me! (Remote Worker)",
    ]

    RECURRENCE = ["Daily", "Monthly", "Yearly"]

    PURCHASE_TYPES = {
      "Software" => 0,
      "Training/Event" => 1,
      "Office Supply/Miscellaneous" => 2,
      "Hardware" => 3,
      "Micropurchase" => 5,
      "Other" => 4,
    }.freeze

    enum purchase_type: PURCHASE_TYPES

    # must define before include PurchaseCardMixin
    def self.purchase_amount_column_name
      :cost_per_unit
    end

    include ClientDataMixin
    include PurchaseCardMixin

    validates :cost_per_unit, presence: true
    validates :quantity, numericality: {
      greater_than_or_equal_to: 1
    }, presence: true
    validates :product_name_and_description, presence: true
    validates :purchase_type, presence: true
    validates :recurring_interval, presence: true, if: :recurring

    def steps_list
      [
        Steps::Approval.new(user: User.for_email(Gsa18f::Procurement.approver_email)),
        Steps::Purchase.new(user: User.for_email(Gsa18f::Procurement.purchaser_email(purchase_type)))
      ]
    end

    def initialize_steps
      proposal.add_initial_steps(steps_list)
    end

    def total_price
      (cost_per_unit * quantity) || 0.0
    end

    # may be replaced with paper-trail or similar at some point
    def version
      updated_at.to_i
    end

    def name
      product_name_and_description
    end

    def editable?
      true
    end

    def urgency_string
      URGENCY[urgency]
    end

    def public_identifier
      "##{proposal.id}"
    end

    def purchaser
      purchasers.first
    end

    def self.approver_email
      user_with_role("gsa18f_approver").email_address
    end

    def self.purchaser_email(request_type = nil)
      if request_type == "Micropurchase"
        user_with_role("gsa18f_micropurchase_purchaser").email_address
      else
        user_with_role("gsa18f_purchaser").email_address
      end
    end

    def self.user_with_role(role_name)
      users = User.active.with_role(role_name).where(client_slug: "gsa18f")
      if users.empty?
        fail "Missing User with role #{role_name} -- did you run rake db:migrate and rake db:seed?"
      end

      users.first
    end

    def self.permitted_params(params, _procurement_instance)
      permitted = Gsa18f::ProcurementFields.new.relevant(params[:gsa18f_procurement][:recurring])
      params.require(:gsa18f_procurement).permit(*permitted)
    end

    def self.special_keys
      %w(type_of_event urgency is_tock_billable date_requested recurring client_billed end_date start_date)
    end

    def self.display_update_type_of_event(obj)
      Gsa18f::Event::EVENT_TYPES.keys[obj[:value].to_i]
    end

    def self.display_update_recurring(obj)
      obj[:value] == true ? "This is recurring" : "This is not recurring"
    end

    def self.display_update_is_tock_billable(obj)
      obj[:value] == true ? "This project is billable" : "This project is not billable"
    end

    def self.display_update_client_billed(obj)
      obj[:value] == true ? "The client has been billed" : "The client has not been billed"
    end

    def self.display_update_urgency(obj)
      Gsa18f::Procurement::URGENCY[obj[:value].to_i]
    end

    def self.display_update_date_requested(obj)
      obj[:value].strftime("%b %e, %Y")
    end

    def self.display_update_end_date(obj)
      obj[:value].strftime("%b %e, %Y")
    end

    def self.display_update_start_date(obj)
      obj[:value].strftime("%b %e, %Y")
    end
  end
end
