describe 'CommunicartsController' do
  describe "POST /communicarts/send_cart" do
    before do
      expect(Dispatcher).to receive(:deliver_new_proposal_emails)

      approval_group = FactoryGirl.create(:approval_group_with_approvers_and_requester, name: 'MyApprovalGroup')
      expect(ApprovalGroup).to receive(:find_by).and_return(approval_group)
    end

    it "makes a successful request" do
      params = {
        cartName: "Q1 Test Cart",
        cartNumber: "2867637",
        category: "initiation",
        email: "test-email@some-dot-gov.gov",
        fromAddress: "",
        gsaUserName: "",
        initiationComment: "\r\n\r\nHi, this is a comment, I hope it works!\r\nThis is the second line of the comment.",
        approvalGroup: "MyApprovalGroup"
      }

      post "/send_cart", params
      expect(response.status).to eq 201
    end
  end

  describe 'PUT /approval_response' do
    context "without a token" do
      it "accepts responses from a signed-in delegate" do
        cart = FactoryGirl.create(:cart_with_approvals)
        approval = cart.approvals.first
        approver = approval.user

        # TODO move to factory trait
        delegate = FactoryGirl.create(:user)
        approver.add_delegate(delegate)

        login_as(delegate)
        params = {
          cart_id: cart.id.to_s,
          approver_action: 'approve'
        }

        put '/approval_response', params

        approval.reload
        expect(approval.status).to eq('approved')
        expect(approval.user).to eq(delegate)
      end

      it "redirects them to log in when not signed in"
    end
  end
end
