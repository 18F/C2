describe CommentsController do
  describe 'permission checking' do
    let (:proposal) { FactoryGirl.create(:proposal, :with_approvers,
                                         :with_observers, :with_requester,
                                         :with_cart) }
    let (:params) { {cart_id: proposal.cart.id,
                     comment: {comment_text: 'Some comment'}} }

    it "allows the requester to comment" do
      login_as(proposal.requester)
      post :create, params
      expect(flash[:success]).to be_present
      expect(flash[:error]).not_to be_present
      expect(response).to redirect_to(proposal.cart)
    end

    it "allows an approver to comment" do
      login_as(proposal.approvers[0])
      post :create, params
      expect(flash[:success]).to be_present
      expect(flash[:alert]).not_to be_present
      expect(response).to redirect_to(proposal.cart)
    end

    it "allows an observer to comment" do
      login_as(proposal.observers[0])
      post :create, params
      expect(flash[:success]).to be_present
      expect(flash[:alert]).not_to be_present
      expect(response).to redirect_to(proposal.cart)
    end

    it "allows a delegate to comment" do
      approver = proposal.approvals.first.user
      delegate = FactoryGirl.create(:user)
      approver.add_delegate(delegate)

      login_as(delegate)

      expect {
        post :create, params
      }.to change{ proposal.comments.count }.from(0).to(1)
    end

    it "does not allow others to comment" do
      login_as(FactoryGirl.create(:user))
      post :create, params
      expect(flash[:success]).not_to be_present
      expect(flash[:alert]).to be_present
      expect(response).to redirect_to(carts_path)
    end
  end
end
