require 'spec_helper'
require 'request_helper'

describe 'CommunicartsController' do
  describe "POST /communicarts/send_cart" do
    before do
      ENV.stub(:[])
      ENV.stub(:[]).with('NOTIFICATION_TO_EMAIL').and_return('george.jetson@spacelysprockets.com')

      params = CommunicartMailer.default_params.merge({from:'reply@communicart-stub.com'})
      CommunicartMailer.stub(:default_params).and_return(params)
      CommunicartsController.any_instance.stub(:total_price_from_params)
      CommunicartMailer.stub_chain(:cart_notification_email, :deliver)

      approval_group = FactoryGirl.create(:approval_group_with_approvers_and_requester, name: 'MyApprovalGroup')
      ApprovalGroup.stub(:find_by).and_return(approval_group)
    end

    it "makes a successful request" do
      post "/send_cart", cart_initialize_params
      expect(response.status).to eq 200
    end

    it "invokes two email messages based on approval group" do
      mock_mailer = double
      CommunicartMailer.stub(:cart_notification_email).and_return(mock_mailer)
      mock_mailer.should_receive(:deliver).exactly(2).times

      post "/send_cart", cart_initialize_params
      expect(response.status).to eq 200
    end
  end

end
