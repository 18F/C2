module Populator
  # singleton
  # https://practicingruby.com/articles/ruby-and-the-singleton-pattern-dont-get-along
  extend self

  def create_carts_with_approvals(n=10)
    n.times do |i|
      cart = FactoryGirl.create(:cart)

      approval1 = cart.add_approver("approver#{i}a@example.com")
      approval1.create_api_token!

      cart.add_approver("approver#{i}b@example.com")
      cart.add_observer("observer#{i}a@example.com")
      cart.add_observer("observer#{i}b@example.com")
      cart.add_requester("requester#{i}@example.com")
    end
  end

  def random_bool(pct_true=0.5)
    rand < pct_true
  end

  def random_ncr_data
    50.times do |i|
      requested_at = rand(3.months.ago..1.day.ago)
      proposal = FactoryGirl.create(:proposal, created_at: requested_at, updated_at: requested_at)
      work_order = FactoryGirl.create(:ncr_work_order,
        emergency: random_bool(0.1),
        proposal: proposal,
        vendor: Faker::Company.name
      )

      unless work_order.emergency
        # TODO randomly approve approvals and proposals at different times
      end

      # TODO add random comments
    end
  end
end
