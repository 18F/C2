require 'request_helper'

describe 'CommunicartsController' do
  describe "POST /communicarts/send_cart" do
    before do
      params = CommunicartMailer.default_params.merge({from:'reply@communicart-stub.com'})
      expect(Dispatcher).to receive(:deliver_new_cart_emails)

      approval_group = FactoryGirl.create(:approval_group_with_approver_and_requester_approvals, name: 'MyApprovalGroup')
      expect(ApprovalGroup).to receive(:find_by).and_return(approval_group)
    end

    it "makes a successful request" do
      post "/send_cart", cart_initialize_params
      expect(response.status).to eq 201
    end
  end
end
