describe 'carts' do
  describe 'GET /carts/:id' do
    it "can be viewed by a delegate" do
      cart = FactoryGirl.create(:cart, :with_requester)
      approver = FactoryGirl.create(:user, :with_delegate)
      cart.proposal.approvals.create!(user: approver)

      delegate = approver.outgoing_delegates.first.assignee
      login_as(delegate)

      get "/carts/#{cart.id}"

      expect(response.status).to eq(200)
    end
  end
end
