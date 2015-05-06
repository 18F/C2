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
end
