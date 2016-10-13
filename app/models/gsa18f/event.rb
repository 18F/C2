module Gsa18f
  # Make sure all table names use 'gsa18f_XXX'
  def self.table_name_prefix
    "gsa18f_"
  end

  class Event < ActiveRecord::Base
    URGENCY = {
      10 => "I need it yesterday",
      20 => "I'm patient but would like w/in a week",
      30 => "Whenever"
    }.freeze

    OFFICES = [
      "DC",
      "Chicago",
      "Dayton",
      "New York",
      "San Francisco",
      "Me! (Remote Worker)"
    ].freeze

    RECURRENCE = %w(Daily Monthly Yearly).freeze

    EVENT_TYPES = {
      "Conference" => 0,
      "Training" => 1
    }.freeze

    enum type_of_event: EVENT_TYPES

    # must define before include PurchaseCardMixin
    def self.purchase_amount_column_name
      :cost_per_unit
    end

    def self.min_purchase_amount
      0
    end

    include ClientDataMixin

    validates :supervisor_id, presence: true
    validates :duty_station, presence: true
    validates :title_of_event, presence: true
    validates :event_provider, presence: true
    validates :purpose, presence: true
    validates :justification, presence: true
    validates :link, presence: true
    validates :instructions, presence: true
    validates :estimated_travel_expenses, numericality: {
      greater_than_or_equal_to: 1,
      message: "must be greater than or equal to #{ActiveSupport::NumberHelper.number_to_currency(1)}"
    }, presence: true, if: :travel_required
    validates name.constantize.purchase_amount_column_name, numericality: {
      greater_than_or_equal_to: 1.0,
      message: "must be greater than or equal to #{ActiveSupport::NumberHelper.number_to_currency(1)}, unless the event is free."
    }, presence: true, unless: :free_event

    def steps_list
      [
        Steps::Approval.new(user: User.for_email(Gsa18f::Event.talent_approver_email)),
        Steps::Approval.new(user: User.for_email(Gsa18f::Event.approver_email)),
        Steps::Approval.new(user: User.for_email(Gsa18f::Event.purchaser_email))
      ]
    end

    def setup_approvals_and_observers
      manager = ApprovalManager.new(self)
      manager.setup_approvals_and_observers
    end

    def setup_and_email_subscribers(comment)
      Gsa18f::Gsa18fUpdater.new(
        gsa18f_proposal: self,
        update_comment: comment
      ).run
    end

    def initialize_steps
      proposal.add_initial_steps(steps_list)
    end

    def product_name_and_description
      title_of_event
    end

    def total_price
      cost_per_unit || 0.0
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
      ""
    end

    def public_identifier
      "##{proposal.id}"
    end

    def purchaser
      purchasers.first
    end

    def self.special_keys
      %w(supervisor_id start_date end_date cost_per_unit)
    end

    def self.talent_approver_email
      user_with_role("gsa18f_talent_approver").email_address
    end

    def self.approver_email
      user_with_role("gsa18f_approver").email_address
    end

    def self.purchaser_email
      user_with_role("gsa18f_purchaser").email_address
    end

    def self.user_with_role(role_name)
      Gsa18f::Procurement.user_with_role(role_name)
    end

    def self.permitted_params(params, _procurement_instance)
      permitted = Gsa18f::EventFields.new.relevant
      params.require(:gsa18f_event).permit(*permitted)
    end

    def self.display_update_start_date(obj)
      obj[:value].strftime("%b %d, %Y")
    end

    def self.display_update_end_date(obj)
      obj[:value].strftime("%b %d, %Y")
    end

    def self.display_update_cost_per_unit(obj)
      format("%.2f", Gsa18f::Event.find(obj[:data].id).cost_per_unit)
    end

    def self.display_update_supervisor_id(obj)
      if obj[:data].supervisor_id.is_a? Integer
        id = obj[:data].supervisor_id
        supervisor = User.find_by(id: id) ? User.find(id).full_name : "--"
        obj[:value] = supervisor
      end
      obj[:value]
    end
  end
end
