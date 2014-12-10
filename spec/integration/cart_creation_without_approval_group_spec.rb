describe 'Creating a cart without an approval group' do

  let(:params_request_1) {
  '{
      "cartName": "A Cart With No Approvals",
      "cartNumber": "13579",
      "approvalGroup": null,
      "category": "initiation",
      "email": "test.email@some-dot-gov.gov",
      "fromAddress": "requester-pcard-holder@some-dot-gov.gov",
      "toAddress": ["some-approver-1@some-dot-gov.gov","some-approver-2@some-dot-gov.gov"],
      "gsaUserName": "",
      "initiationComment": "I have to say that this is great.",
      "properties": {
        "configType":"Standard",
        "cpu":"Intel Core i5-3320M processor or better Intel CPU",
        "memory":"6.0 GB 1600 MHz ",
        "displayTechnology":"Intel 4000 or higher ",
        "hardDrive":"320GB 7200RPM",
        "operatingSystem":"Windows 7 64 bit",
        "displaySize":"Windows 7 64 bit",
        "sound ":"Analog Stereo Output",
        "speakers":"Integrated Stereo",
        "opticalDrive ":"8x DVD +/- RW",
        "mouse ":"Trackpoint pad & optical USB w/ scroll ",
        "keyboard ":"Integrated"
        },
      "cartItems": [
        {
          "vendor": "DOCUMENT IMAGING DIMENSIONS, INC.",
          "description": "ROUND RING VIEW BINDER WITH INTERIOR POC",
          "url": "/advantage/catalog/product_detail.do?&oid=704213980&baseOid=&bpaNumber=GS-02F-XA002",
          "notes": "",
          "qty": "24",
          "details": "Direct Delivery 3-4 days delivered ARO",
          "socio": [],
          "partNumber": "7510-01-519-4381",
          "price": "$2.46",

          "properties": {
            "somekey1":"value1",
            "somekey2":"value2"
          },

          "features": [
              "sale"
          ],
          "traits": {
              "socio": [
                  "s",
                  "w"
              ],
              "features": [
                  "bpa"
              ],
              "green": ""
           }
        }
      ]
    }'
  }

  before do
    ENV['NOTIFICATION_FROM_EMAIL'] = 'sender@some-dot_gov.gov'

    @json_params_1 = JSON.parse(params_request_1)
    expect(User.count).to eq 0
    expect(Cart.count).to eq 0
    expect(Approval.count).to eq 0
  end

  it 'creates new users' do
    post 'send_cart', @json_params_1

    expect(User.count).to eq 3
    expect(User.first.email_address).to eq 'some-approver-1@some-dot-gov.gov'
    expect(User.last.email_address).to eq 'requester-pcard-holder@some-dot-gov.gov'
  end

  it 'does not create an approval group' do
    expect{ post 'send_cart', @json_params_1 }.not_to change{ ApprovalGroup.count }
  end

  it 'creates approvals' do
    post 'send_cart', @json_params_1
    expect(Approval.all.map(&:role)).to match_array ['approver','approver','requester']
    expect(Approval.count).to eq 3
  end

  it 'delivers emails to approver email addresses indicated in the toAddress field' do
    post 'send_cart', @json_params_1
    expect(ActionMailer::Base.deliveries.count).to eq 2
  end

  it 'adds initial comments from the requester' do
    post 'send_cart', @json_params_1
    expect(Cart.first.comments.first.comment_text).to eq 'I have to say that this is great.'
  end

  context 'cart' do
    it 'sets the appropriate cart values' do
      post 'send_cart', @json_params_1
      expect(Cart.first.name).to eq "A Cart With No Approvals"
    end

    it 'adds cart properties' do
      post 'send_cart', @json_params_1
      expect(Cart.first.properties.count).to eq 12
    end
  end

  context 'cart items' do
    it 'adds cart items to the cart' do
      expect{ post 'send_cart', @json_params_1 }.to change{CartItem.count}.by(1)
    end

    it 'creates cart item properties' do
      expect(Property.count).to eq 0
      post 'send_cart', @json_params_1
      expect(Property.where(hasproperties_type: "CartItem").size).to eq 2
    end
  end

end
