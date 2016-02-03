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

    RECURRENCE = ["Daily", "Monthy", "Yearly"]

    PURCHASE_TYPES = {
      "Software" => 0,
      "Training/Event" => 1,
      "Office Supply/Miscellaneous" => 2,
      "Hardware" => 3,
      "Other" => 4,
    }

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

    def fields_for_display
      Gsa18f::ProcurementFields.new(self).display
    end

    def add_steps
      steps = [
        Steps::Approval.new(user: User.for_email(Gsa18f::Procurement.approver_email)),
        Steps::Purchase.new(user: User.for_email(Gsa18f::Procurement.purchaser_email)),
      ]
      proposal.add_initial_steps(steps)
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
      user_with_role('gsa18f_approver').email_address
    end

    def self.purchaser_email
      user_with_role('gsa18f_purchaser').email_address
    end

    def self.user_with_role(role_name)
      users = User.active.with_role(role_name).where(client_slug: 'gsa18f')
      if users.empty?
        fail "Missing User with role #{role_name} -- did you run rake db:migrate and rake db:seed?"
      end

      users.first
    end
  end
end
