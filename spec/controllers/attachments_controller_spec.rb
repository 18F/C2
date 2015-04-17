describe AttachmentsController do
  describe 'permission checking' do
    let (:proposal) { FactoryGirl.create(:proposal, :with_approvers,
                                         :with_observers, :with_requester,
                                         :with_cart) }
    let (:params) {{
      cart_id: proposal.cart.id, 
      attachment: { file: fixture_file_upload('icon-user.png', 'image/png') }
    }}
                     
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

    it "does not allow others to comment" do
      login_as(FactoryGirl.create(:user))
      post :create, params
      expect(flash[:success]).not_to be_present
      expect(flash[:alert]).to be_present
      expect(response).to redirect_to(carts_path)
    end
  end
end
