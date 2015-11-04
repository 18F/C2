describe ObservationsController do
  describe "#create" do
    let (:proposal) { create(:proposal) }

    it "requires an email address" do
      login_as(proposal.requester)
      expect{ 
        post :create, proposal_id: proposal.id
      }.to raise_error(ActionController::ParameterMissing)
      expect{ 
        post :create, proposal_id: proposal.id, observation: {user: "abc"}
      }.to raise_error(ActionController::ParameterMissing)
      expect{ 
        post :create, proposal_id: proposal.id, observation: {user: {name: "abc"}}
      }.to raise_error(ActionController::ParameterMissing)
      expect{ 
        post :create, proposal_id: proposal.id, observation: {user: {email_address: ""}}
      }.to raise_error(ActionController::ParameterMissing)
    end
  end

  describe "#destroy" do
    let (:proposal) { create(:proposal, :with_observers) }
    let (:observation) { proposal.observations.first }

    it "redirect with a notice when successful" do
      login_as(proposal.requester)
      post :destroy, proposal_id: proposal.id, id: observation.id
      expect(response).to redirect_to(proposal_path(proposal))
      expect(flash[:success]).not_to be_empty
      expect(flash[:warning]).to be_nil
    end

    it "responds with a warning if unsuccessful" do
      login_as(create(:user))
      post :destroy, proposal_id: proposal.id, id: observation.id
      expect(response.status).to eq(403)
      expect(flash[:success]).to be_nil
      expect(flash[:alert]).to be_nil
    end
  end
end
