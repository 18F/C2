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
    
    validates :cost_per_unit, numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 3000
    }
    validates :quantity, numericality: {
      greater_than_or_equal_to: 1
    }
    validates :product_name_and_description, presence: true

    def init_and_save_cart(requester)
      cart = Cart.create(
        proposal_attributes: {flow: 'linear', client_data: self}
      )
      cart.set_requester(requester)
      self.add_approvals
      Dispatcher.deliver_new_cart_emails(cart)
      cart
    end
    
    def update_cart(cart)
      cart.proposal.approvals.destroy_all
      self.add_approvals
      cart.restart!
      cart
    end

    def add_approvals
      self.cart.add_approver(approver_email)
    end

    # Ignore values in certain fields if they aren't relevant. May want to
    # split these into different models
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
      Gsa18f::Procurement.relevant_fields(self.recurring)
    end

    def fields_for_display
      attributes = self.relevant_fields
      attributes.map{|key| [Procurement.human_attribute_name(key), self[key]]}
    end

    def client
      "gsa18f"
    end

    # @todo - this is pretty ugly
    def public_identifier
      self.cart.id
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

    protected
    def approver_email
      ENV['GSA18F_APPROVER_EMAIL'] || '18fapprover@gsa.gov'
    end

    def system_approvers
      emails = [self.approver_email]
      emails
    end
  end
end
