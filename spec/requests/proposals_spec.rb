describe 'proposals' do
  describe 'GET /proposals/:id' do
    it "can be viewed by a delegate" do
      proposal = FactoryGirl.create(:proposal, :with_cart)
      approver = FactoryGirl.create(:user, :with_delegate)
      proposal.approvals.create!(user: approver)

      delegate = approver.outgoing_delegates.first.assignee
      login_as(delegate)

      get "/proposals/#{proposal.id}"

      expect(response.status).to eq(200)
    end
  end

  describe 'POST /proposals/:id/approve' do
    it "updates the status of the Proposal" do
      proposal = FactoryGirl.create(:proposal, :with_approver)
      approver = proposal.approvers.first
      login_as(approver)

      post "/proposals/#{proposal.id}/approve"

      expect(response).to redirect_to("/proposals/#{proposal.id}")
      proposal.reload
      expect(proposal.status).to eq('approved')
    end

    it "fails if not signed in" do
      proposal = FactoryGirl.create(:proposal, :with_approver)
      post "/proposals/#{proposal.id}/approve"

      expect(response.status).to redirect_to('/')
      proposal.reload
      expect(proposal.status).to eq('pending')
    end

    it "fails if user is not involved with the request" do
      proposal = FactoryGirl.create(:proposal)
      stranger = FactoryGirl.create(:user)
      login_as(stranger)

      post "/proposals/#{proposal.id}/approve"

      expect(response.status).to redirect_to('/proposals')
      proposal.reload
      expect(proposal.status).to eq('pending')
    end

    it "supports token auth" do
      proposal = FactoryGirl.create(:proposal, :with_approver)
      approval = proposal.approvals.first
      token = approval.create_api_token!

      post "/proposals/#{proposal.id}/approve", cch: token.access_token

      expect(response).to redirect_to("/proposals/#{proposal.id}")
      proposal.reload
      expect(proposal.status).to eq('approved')
    end
  end
end
