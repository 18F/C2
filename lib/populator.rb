module Populator
  class << self
    def create_carts_with_approvals
      10.times do |i|
        cart = FactoryGirl.create(:cart)

        approval1 = cart.add_approver("approver#{i}a@example.com")
        approval1.create_api_token!

        cart.add_approver("approver#{i}b@example.com")
        cart.add_observer("observer#{i}a@example.com")
        cart.add_observer("observer#{i}b@example.com")
        cart.add_requester("requester#{i}@example.com")
      end
    end
  end
end
