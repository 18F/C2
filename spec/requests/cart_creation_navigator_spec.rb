describe 'Creating a cart' do
  before do
    FactoryGirl.create(:approval_group_with_approvers_and_requester, name: "firstApprovalGroup")
    approval_group_2 = FactoryGirl.create(:approval_group, name: "secondApprovalGroup")
    FactoryGirl.create(:user, email_address: "test.email.only@some-dot-gov.gov")

    requester1 = User.create!(email_address: 'requester-approval-group2@some-dot-gov.gov')
    UserRole.create!(user_id: requester1.id, approval_group_id: approval_group_2.id, role: 'requester')
  end


  let(:params_request_1) {
    '{
      "cartName": "",
      "approvalGroup": "firstApprovalGroup",
      "cartNumber": "13579",
      "category": "initiation",
      "email": "test.email@some-dot-gov.gov",
      "fromAddress": "approver1@some-dot-gov.gov",
      "gsaUserName": "",
      "initiationComment": "\r\n\r\nHi, this is a comment from the first approval group, I hope it works!\r\nThis is the second line of the comment.",
      "properties": {
        "origin": "navigator",
        "contractingVehicle": "IT Schedule 70",
        "LOCATION": "LSA",
        "configuration": {
            "cpu": "Intel Core i5-3320M processor or better Intel CPU",
            "memory": "6.0 GB 1600 MHz",
            "displayTechnology": "Intel 4000 or higher",
            "hardDrive": "320GB 7200RPM",
            "operatingSystem": "Windows 7 64 bit",
            "displaySize": "Analog Stereo Output",
            "sound": "Analog Stereo Output",
            "speakers": "Integrated Stereo",
            "opticalDrive": "8x DVD +/- RW",
            "mouse": "Trackpoint pad & optical USB w/ scroll",
            "keyboard": "Integrated"
        },
        "lsaSates": [
            "MD",
            "DC",
            "VA",
            "WV"
        ]
      }
    }'
  }

  let(:params_request_2) {
  '{
      "cartName": "",
      "approvalGroup": "secondApprovalGroup",
      "cartNumber": "13579",
      "category": "initiation",
      "email": "test.email@some-dot-gov.gov",
      "fromAddress": "approver1@some-dot-gov.gov",
      "gsaUserName": "",
      "initiationComment": "\r\n\r\nHi, this is a comment from the second approval group, I hope it works!\r\nThis is the second line of the comment."
    }'
  }

  context 'cart origin property' do
    it 'added origin symbol' do
      @json_params_1 = JSON.parse(params_request_1)

      expect(Cart.count).to eq 0

      post 'send_cart', @json_params_1
      expect(Cart.count).to eq 1
      cart = Cart.first
      expect(cart.getProp('origin')).to eq 'navigator'
    end
  end
end
