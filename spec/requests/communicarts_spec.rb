require 'spec_helper'
require 'request_helper'

describe 'CommunicartsController' do
  describe "POST /communicarts/send_cart" do
    before do
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with('NOTIFICATION_TO_EMAIL').and_return('george.jetson@spacelysprockets.com')

      params = CommunicartMailer.default_params.merge({from:'reply@communicart-stub.com'})
      allow(CommunicartMailer).to receive(:default_params).and_return(params)
      allow_any_instance_of(CommunicartsController).to receive(:total_price_from_params)
      allow(CommunicartMailer).to receive_message_chain(:cart_notification_email, :deliver)

      approval_group = FactoryGirl.create(:approval_group_with_approver_and_requester_approvals, name: 'MyApprovalGroup')
      allow(ApprovalGroup).to receive(:find_by).and_return(approval_group)
    end

    it "makes a successful request" do
      post "/send_cart", cart_initialize_params
      expect(response.status).to eq 201
    end

    it "invokes two email messages based on approval group" do
      mock_mailer = double
      allow(CommunicartMailer).to receive(:cart_notification_email).and_return(mock_mailer)
      expect(mock_mailer).to receive(:deliver).exactly(2).times

      post "/send_cart", cart_initialize_params
      expect(response.status).to eq 201
    end
  end

end
