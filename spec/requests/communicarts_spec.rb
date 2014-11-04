require 'spec_helper'
require 'request_helper'

describe 'CommunicartsController' do
  describe "POST /communicarts/send_cart" do

    #App creation
    let(:app) { FactoryGirl.create(:app) }
    let(:headers) {
      { 'Content-MD5' => "",
        'Content-Type' => "text/plain",
        'Date' => "Mon, 23 Jan 1984 03:29:56 GMT" }
    }

    let(:uri) { '/send_cart' }
    let(:request) {
      uri = URI('http://send_cart')
      Net::HTTP.post_form(uri, cart_initialize_params)
    }
    let(:signed_request) { request.sign!(request, app.access_id, app.secret_key) }

    before do
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with('NOTIFICATION_TO_EMAIL').and_return('george.jetson@spacelysprockets.com')

      params = CommunicartMailer.default_params.merge({from:'reply@communicart-stub.com'})
      allow(CommunicartMailer).to receive(:default_params).and_return(params)
      allow_any_instance_of(CommunicartsController).to receive(:total_price_from_params)
      allow(CommunicartMailer).to receive_message_chain(:cart_notification_email, :deliver)

      approval_group = FactoryGirl.create(:approval_group_with_approver_and_requester_approvals, name: 'MyApprovalGroup')
      allow(ApprovalGroup).to receive(:find_by).and_return(approval_group)

      request['Content-MD5'] = ""
      request['Content-Type'] = "text/plain"
      request['Date'] = Time.now
    end

    it "makes a successful request" do
      # post "/send_cart", cart_initialize_params, headers
      post signed_request
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
