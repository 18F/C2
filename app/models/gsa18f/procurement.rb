module Gsa18f
  # Make sure all table names use 'gsa18f_XXX'
  def self.table_name_prefix
    'gsa18f_'
  end

  DATA = YAML.load_file("#{Rails.root}/config/data/18f.yaml")

  class Procurement < ActiveRecord::Base
    URGENCY = DATA['URGENCY']
    OFFICES = DATA['OFFICES']
    RECURRENCE = DATA['RECURRENCE']

    # must define before include PurchaseCardMixin
    def self.purchase_amount_column_name
      :cost_per_unit
    end

    include ProposalDelegate
    include PurchaseCardMixin

    validates :cost_per_unit, presence: true
    validates :quantity, numericality: {
      greater_than_or_equal_to: 1
    }, presence: true
    validates :product_name_and_description, presence: true
    validates :recurring_interval, presence: true, if: :recurring

    def add_steps
      steps = [
        Steps::Approval.new(user: User.for_email(Gsa18f::Procurement.approver_email)),
        Steps::Purchase.new(user: User.for_email(Gsa18f::Procurement.purchaser_email)),
      ]
      proposal.add_initial_steps(steps)
    end

    def self.relevant_fields(recurring)
      fields = [:office, :justification, :link_to_product, :quantity,
        :date_requested, :urgency, :additional_info, :cost_per_unit,
        :product_name_and_description, :recurring]
      if recurring
        fields += [:recurring_interval, :recurring_length]
      end
      fields
    end

    def relevant_fields
      Gsa18f::Procurement.relevant_fields(recurring)
    end

    def fields_for_display
      attributes = self.relevant_fields
      attributes.map! {|key| [Procurement.human_attribute_name(key), self[key]]}
      attributes.push(["Total Price", total_price])
    end

    def total_price
      (self.cost_per_unit * self.quantity) || 0.0
    end

    # may be replaced with paper-trail or similar at some point
    def version
      self.updated_at.to_i
    end

    def name
      self.product_name_and_description
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
      purchase_step ? purchase_step.user : nil
    end

    def self.approver_email
      self.user_with_role('gsa18f_approver').email_address
    end

    def self.purchaser_email
      self.user_with_role('gsa18f_purchaser').email_address
    end

    def self.user_with_role(role_name)
      users = User.active.with_role(role_name).where(client_slug: 'gsa18f')
      if users.empty?
        fail "Missing User with role #{role_name} -- did you run rake db:migrate and rake db:seed?"
      end

      users.first
    end

    private

    def purchase_step
      steps.select{|step| step.is_a?(Steps::Purchase)}.first
    end
  end
end
