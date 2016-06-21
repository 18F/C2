describe CommentsController do
  before(:all) { ENV["DISABLE_EMAIL"] = nil }
  after(:all)  { ENV["DISABLE_EMAIL"] = "Yes" }

  describe "permission checking" do
    let(:proposal) { create(:proposal, :with_parallel_approvers, :with_observers) }
    let(:params) do
      { proposal_id: proposal.id, comment: { comment_text: "Some comment" } }
    end

    context "requester comments" do
      it "allows the requester to comment" do
        login_as(proposal.requester)
        post :create, params
        expect(flash[:success]).to be_present
        expect(flash[:error]).not_to be_present
        expect(response).to redirect_to(proposal)
      end

      it "sends a comment email to approvers and observers" do
        ENV["DISABLE_EMAIL"] = nil

        login_as(proposal.requester)

        expect do
          post :create, params
        end.to change { deliveries.length }.from(0).to(4)

        ENV["DISABLE_EMAIL"] = "Yes"
      end
    end

    context "comment fails to save" do
      it "shows a helpful error messsage" do
        login_as(proposal.approvers[0])

        post :create, proposal_id: proposal.id, comment: { comment_text: "" }

        expect(flash[:success]).not_to be_present
        expect(flash[:error]).to be_present
        expect(response).to redirect_to(proposal_path(proposal))
      end
    end

    it "allows an approver to comment" do
      login_as(proposal.approvers[0])
      post :create, params
      expect(flash[:success]).to be_present
      expect(flash[:alert]).not_to be_present
      expect(response).to redirect_to(proposal)
    end

    it "allows an observer to comment" do
      login_as(proposal.observers[0])
      post :create, params
      expect(flash[:success]).to be_present
      expect(flash[:alert]).not_to be_present
      expect(response).to redirect_to(proposal)
    end

    it "allows a delegate to comment and adds delegate as observer" do
      approver = proposal.approvers.first
      delegate = create(:user)
      approver.add_delegate(delegate)

      login_as(delegate)

      expect do
        post :create, params
      end.to change { proposal.comments.count }.from(0).to(1)
      expect(proposal.comments.last.user).to eq(delegate)
      expect(proposal.observers).to include(delegate)
    end

    it "does not allow others to comment" do
      login_as(create(:user))
      post :create, params
      expect(response.status).to eq(403)
    end
  end
end
