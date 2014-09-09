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
      "fromAddress": "approver1@some-dot-gov.gov",
      "toAddress": ["some-approver-1@some-dot-gov.gov","some-approver-2@some-dot-gov.gov"],
      "gsaUserName": "",
      "initiationComment": "\r\n\r\nHi, this is a comment from the first approval group, I hope it works!\r\nThis is the second line of the comment.",
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

  it 'should create new users' do
    @json_params_1 = JSON.parse(params_request_1)
    expect(User.count).to eq 0
    expect(Cart.count).to eq 0
    expect(Approval.count).to eq 0

    post 'send_cart', @json_params_1

    expect(User.first.email_address).to eq 'some-approver-1@some-dot-gov.gov'
    expect(User.last.email_address).to eq 'some-approver-2@some-dot-gov.gov'
    expect(Approval.all.map(&:role)).to eq ['approver','approver']
    expect(Approval.count).to eq 2
    expect(Cart.first.name).to eq "A Cart With No Approvals"

  end

end
