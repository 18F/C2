describe ObservationsController do
  let (:proposal) { FactoryGirl.create(:proposal, :with_observers) }
  let (:observation) { proposal.observations.first }
  describe "#destroy" do
    it "redirect with a notice when successful" do
      login_as(observation.user)
      post :destroy, proposal_id: proposal.id, id: observation.id
      expect(response).to redirect_to(proposal_path(proposal))
      expect(flash[:success]).not_to be_empty
      expect(flash[:warning]).to be_nil
    end

    it "redirects with a warning if unsuccessful" do
      login_as(proposal.observers.second)
      post :destroy, proposal_id: proposal.id, id: observation.id
      expect(response).to redirect_to(proposals_path)
      expect(flash[:success]).to be_nil
      expect(flash[:alert]).not_to be_empty
    end
  end
end
