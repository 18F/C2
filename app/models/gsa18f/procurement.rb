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

    # TODO include ProposalDelegate

    has_one :proposal, as: :client_data
    # TODO remove the dependence
    has_one :cart, through: :proposal

    after_initialize :set_defaults
    
    validates :cost_per_unit, numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 3000
    }
    validates :quantity, numericality: {
      greater_than_or_equal_to: 1
    }
    validates :product_name_and_description, presence: true
    
    # attribute :requester, :user
    # attribute :office, :string
    # attribute :justification, :text
    # attribute :link_to_product, :string
    # attribute :quantity, :integer
    # attribute :date_requested, :datetime
    # attribute :urgency, :string
    # attribute :additional_info, :string
    # attribute :cost_per_unit, :decimal
    # attribute :product_name_and_description, :text
    # attribute :recurring, :boolean
    # attribute :recurring_interval, :string
    # attribute :recurring_length, :integer
    # attribute :origin, :string

    def set_defaults
      # self.not_to_exceed ||= false
      # self.emergency ||= false
    end

    def init_and_save_cart(approver_email, requester)
      cart = Cart.create(
        proposal_attributes: {flow: 'linear', client_data: self}
      )
      cart.set_requester(requester)
      self.add_approvals(approver_email)
      Dispatcher.deliver_new_cart_emails(cart)
      cart
    end
    
    def update_cart(approver_email, cart)
      cart.proposal.approvals.destroy_all
      self.add_approvals(self.system_approvers)
      cart.restart!
      cart
    end

    def add_approvals(approver_email)
      self.cart.add_approver(self.system_approvers)
    end

    # Ignore values in certain fields if they aren't relevant. May want to
    # split these into different models
    def self.relevant_fields(recurring)
      fields = [:office, :justification, :link_to_product, :quantity,
        :date_requested, :urgency, :additional_info, :cost_per_unit, 
        :product_name_and_description]
      case recurring
      when "1"
        fields + [:recurring_interval, :recurring_length]
      end
    end

    def relevant_fields
      Ncr::WorkOrder.relevant_fields(self.recurring)
    end
     # attribute :requester, :user
    # attribute :office, :string
    # attribute :justification, :text
    # attribute :link_to_product, :string
    # attribute :quantity, :integer
    # attribute :date_requested, :datetime
    # attribute :urgency, :string
    # attribute :additional_info, :string
    # attribute :cost_per_unit, :decimal
    # attribute :product_name_and_description, :text
    # attribute :recurring, :boolean
    # attribute :recurring_interval, :string
    # attribute :recurring_length, :integer
    # attribute :origin, :string
    # Methods for Client Data interface
    def fields_for_display
      attributes = self.relevant_fields
      attributes.map{|key| [ProposalForm.human_attribute_name(key), self[key]]}
    end

    def client
      "gsa18f"
    end

    # @todo - this is pretty ugly
    def public_identifier
      self.cart.id
    end

    def total_price
      self.amount || 0.0
    end

    # may be replaced with paper-trail or similar at some point
    def version
      self.updated_at.to_i
    end

    protected
    def approver_email
      ENV['GSA18F_APPROVER_EMAIL'] || '18fapprover@gsa.gov'
    end

    def system_approvers
      emails = [self.approver_email]
      emails
    end

    # def approver_email
    #   ENV['GSA18F_APPROVER_EMAIL'] || '18fapprover@gsa.gov'
    # end

    # def set_approver_on(cart)
    #   cart.add_approver(self.approver_email)
    # end

    # def set_origin_on(cart)
    #   cart.set_props(origin: 'gsa18f')
    # end

    # def create_cart
    #   cart = Cart.new(
    #     name: self.product_name_and_description,
    #     proposal_attributes: {flow: 'linear'}
    #   )
    #   if cart.save
    #     self.set_props_on(cart)
    #     self.set_approver_on(cart)
    #     self.set_origin_on(cart)
    #     Dispatcher.deliver_new_cart_emails(cart)
    #   end

    #   cart
    # end

    # def update_cart(cart)
    #   cart.name = self.product_name_and_description
    #   if cart.save
    #     cart.proposal.approvals.destroy_all
    #     # @todo: do we actually want to clear all properties?
    #     cart.clear_props!
    #     self.set_props_on(cart)
    #     self.set_approver_on(cart)
    #     self.set_origin_on(cart)
    #     cart.restart!
    #   end
    #   cart
    # end

    # def set_props_on(cart)
    #   cart.set_props(
    #     office: self.office,
    #     justification: self.justification,
    #     link_to_product: self.link_to_product,
    #     cost_per_unit: self.cost_per_unit,
    #     quantity: self.quantity,
    #     date_requested: self.date_requested,
    #     urgency: self.urgency,
    #     additional_info: self.additional_info,
    #     recurring_interval: self.recurring_interval,
    #     recurring_length: self.recurring_length,
    #     recurring: self.recurring
    #   )
    #   cart.set_requester(self.requester)
    # end

    # def self.from_cart(cart)
    #   relevant_properties = self._attributes.map(&:name).map(&:to_s)
    #   properties = cart.deserialized_properties.select{
    #     |key, val| relevant_properties.include? key
    #   }
    #   form = self.new(properties)
    #   form.product_name_and_description = cart.name
    #   form
    # end
  end
end
