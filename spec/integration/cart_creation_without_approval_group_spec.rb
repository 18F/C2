require 'spec_helper'

describe 'Creating a cart without an approval group' do
  before do
    # approval_group_1 = FactoryGirl.create(:approval_group_with_approvers_and_requester, name: "firstApprovalGroup")
    # approval_group_2 = ApprovalGroup.create(name: "secondApprovalGroup")
    # FactoryGirl.create(:user, email_address: "test.email.only@some-dot-gov.gov")

    # requester1 = User.create!(email_address: 'requester-approval-group2@some-dot-gov.gov')
    # UserRole.create!(user_id: requester1.id, approval_group_id: approval_group_2.id, role: 'requester')
  end


  let(:params_request_1) {
  '{
      "cartName": "A Cart With No Approvals",
      "cartNumber": "13579",
      "approvalGroup": "",
      "category": "initiation",
      "email": "test.email@some-dot-gov.gov",
      "fromAddress": "requester-pcard-holder@some-dot-gov.gov",
      "toAddress": ["some-approver-1@some-dot-gov.gov","some-approver-2@some-dot-gov.gov"],
      "gsaUserName": "",
      "initiationComment": "I have to say that this is great.",
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
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    ENV['NOTIFICATION_FROM_EMAIL'] = 'sender@some-dot_gov.gov'

    @json_params_1 = JSON.parse(params_request_1)
    expect(User.count).to eq 0
    expect(Cart.count).to eq 0
    expect(Approval.count).to eq 0
  end

  after do
    ActionMailer::Base.deliveries.clear
  end

  it 'set the appropriate cart values' do
    post 'send_cart', @json_params_1
    expect(Cart.first.name).to eq "A Cart With No Approvals"
  end

  it 'should create new users' do
    post 'send_cart', @json_params_1

    expect(User.count).to eq 3
    expect(User.first.email_address).to eq 'some-approver-1@some-dot-gov.gov'
    expect(User.last.email_address).to eq 'requester-pcard-holder@some-dot-gov.gov'

  end

  it 'does not create an approval group' do
    expect{ post 'send_cart', @json_params_1 }.not_to change{ApprovalGroup.count}.by(1)
  end

  it 'creates approvals' do
    post 'send_cart', @json_params_1
    expect(Approval.all.map(&:role)).to eq ['approver','approver','requester']
    expect(Approval.count).to eq 3
  end

  it 'delivers emails to approver email addresses indicated in the toAddress field' do
    post 'send_cart', @json_params_1
    expect(ActionMailer::Base.deliveries.count).to eq 2
  end

  it 'adds cart items to the cart' do
    expect{ post 'send_cart', @json_params_1 }.to change{CartItem.count}.by(1)
  end

  it 'adds initial comments from the requester' do
    post 'send_cart', @json_params_1
    expect(Cart.first.comments.first.comment_text).to eq 'I have to say that this is great.'
  end

end
