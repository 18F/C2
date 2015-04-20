describe 'proposals' do
  describe 'GET /proposals/:id' do
    it "can be viewed by a delegate" do
      proposal = FactoryGirl.create(:proposal, :with_requester, :with_cart)
      approver = FactoryGirl.create(:user, :with_delegate)
      proposal.approvals.create!(user: approver)

      delegate = approver.outgoing_delegates.first.assignee
      login_as(delegate)

      get "/proposals/#{proposal.id}"

      expect(response.status).to eq(200)
    end
  end
end

