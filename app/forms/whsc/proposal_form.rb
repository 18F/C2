module Whsc
  class ProposalForm
    include SimpleFormObject

    attribute :amount, :decimal
    attribute :description, :text
    attribute :requester, :user
    attribute :vendor, :string

    validates :amount, numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 3000
    }
    validates :description, presence: true
    validates :requester, presence: true
    validates :vendor, presence: true


    def create_cart
      cart = Cart.new(
        flow: 'linear',
        name: self.description
      )
      if cart.save
        cart.set_props(
          vendor: self.vendor,
          amount: self.amount
        )
        cart.set_requester(self.requester)
      end

      cart
    end
  end
end
