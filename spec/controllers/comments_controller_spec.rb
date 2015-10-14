describe CommentsController do
  describe 'permission checking' do
    let (:proposal) { create(:proposal, :with_parallel_approvers, :with_observers) }
    let (:params) {
      { proposal_id: proposal.id, comment: { comment_text: 'Some comment' }}
    }

    context 'requester comments' do
      it 'allows the requester to comment' do
        login_as(proposal.requester)
        post :create, params
        expect(flash[:success]).to be_present
        expect(flash[:error]).not_to be_present
        expect(response).to redirect_to(proposal)
      end

      it 'sends a comment email to approvers and observers' do
        ActionMailer::Base.deliveries.clear
        login_as(proposal.requester)

        post :create, params

        expect(deliveries.length).to eq 4
      end
    end

    it 'allows an approver to comment' do
      login_as(proposal.approvers[0])
      post :create, params
      expect(flash[:success]).to be_present
      expect(flash[:alert]).not_to be_present
      expect(response).to redirect_to(proposal)
    end

    it 'allows an observer to comment' do
      login_as(proposal.observers[0])
      post :create, params
      expect(flash[:success]).to be_present
      expect(flash[:alert]).not_to be_present
      expect(response).to redirect_to(proposal)
    end

    it 'allows a delegate to comment' do
      approver = proposal.approvers.first
      delegate = create(:user)
      approver.add_delegate(delegate)

      login_as(delegate)

      expect {
        post :create, params
      }.to change{ proposal.comments.count }.from(0).to(1)
      expect(Comment.last.user).to eq(delegate)
    end

    it 'does not allow others to comment' do
      login_as(create(:user))
      post :create, params
      expect(flash[:success]).not_to be_present
      expect(flash[:alert]).to be_present
      expect(response).to redirect_to(proposals_path)
    end
  end
end
