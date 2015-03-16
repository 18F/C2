#module Ncr
module Gsa18f
  DATA = YAML.load_file("#{Rails.root}/config/data/18f.yaml")

  class ProposalForm
    include SimpleFormObject

    URGENCY = DATA['URGENCY']
    OFFICES = DATA['OFFICES']
    
    #18f additions
    #attribute :approver_email, :text
    attribute :requester, :user
    attribute :office, :string
    attribute :justification, :text
    attribute :link_to_product, :string
    attribute :quantity, :decimal
    attribute :date_requested, :datetime
    attribute :urgency, :string
    attribute :additional_info, :string
    attribute :cost_per_unit, :decimal
    attribute :product_name_and_description, :text
    attribute :origin, :string

    validates :cost_per_unit, numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 3000
    }
    validates :quantity, numericality: {
      greater_than_or_equal_to: 1
    }
    validates :product_name_and_description, presence: true

    def approver_emails
      emails = ['Richard.L.Miller@gsa.gov']
      emails
    end

    def create_cart
      cart = Cart.new(
        name: self.product_name_and_description,
        proposal_attributes: {flow: 'linear'}
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
      cart.name = self.product_name_and_description
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
        office: self.office,
        justification: self.justification,
        link_to_product: self.link_to_product,
        cost_per_unit: self.cost_per_unit,
        quantity: self.quantity,
        date_requested: self.date_requested,
        urgency: self.urgency,
        additional_info: self.additional_info
      )
      cart.set_requester(self.requester)
    end

    def self.from_cart(cart)
      relevant_properties = self._attributes.map(&:name).map(&:to_s)
      properties = cart.deserialized_properties.select{
        |key, val| relevant_properties.include? key
      }
      form = self.new(properties)
      form.product_name_and_description = cart.name
      form
    end
  end
end
