require 'spec_helper'

describe 'Creating a cart' do
  before do
    approval_group_1 = FactoryGirl.create(:approval_group_with_approvers_and_requester, name: "firstApprovalGroup")
    approval_group_2 = ApprovalGroup.create(name: "secondApprovalGroup")
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
        },
        {
          "vendor": "OFFICE DEPOT",
          "description": "PEN,ROLLER,GELINK,G-2,X-FINE",
          "url": "/advantage/catalog/product_detail.do?&oid=703389586&baseOid=&bpaNumber=GS-02F-XA009",
          "notes": "",
          "qty": "5",
          "details": "Direct Delivery 3-4 days delivered ARO",
          "socio": ["s","w"],
          "partNumber": "PIL31003",
          "price": "$10.29",
          "features": [],
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
        },
        {
          "vendor": "METRO OFFICE PRODUCTS",
          "description": "PAPER,LEDGER,11X8.5",
          "url": "/advantage/catalog/product_detail.do?&oid=681115589&baseOid=&bpaNumber=GS-02F-XA004",
          "notes": "",
          "qty": "3",
          "details": "Direct Delivery 3-4 days delivered ARO",
          "socio": ["s"],
          "partNumber": "WLJ90310",
          "price": "$32.67",
          "features": [],
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

  let(:params_request_2) {
  '{
      "cartName": "",
      "approvalGroup": "secondApprovalGroup",
      "cartNumber": "13579",
      "category": "initiation",
      "email": "test.email@some-dot-gov.gov",
      "fromAddress": "approver1@some-dot-gov.gov",
      "gsaUserName": "",
      "initiationComment": "\r\n\r\nHi, this is a comment from the second approval group, I hope it works!\r\nThis is the second line of the comment.",
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
          "price": "$9.87",
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

  it 'replaces existing cart items and approval group when initializing an existing cart' do
    @json_params_1 = JSON.parse(params_request_1)
    @json_params_2 = JSON.parse(params_request_2)

    expect(Cart.count).to eq 0

    post 'send_cart', @json_params_1

    expect(Cart.count).to eq 1
    cart = Cart.first
    expect(cart.cart_items.count).to eq 3
    expect(cart.cart_items[0].price).to eq 2.46
    expect(cart.cart_items[1].price).to eq 10.29
    expect(cart.cart_items[2].price).to eq 32.67
    expect(cart.approval_group.name).to eq "firstApprovalGroup"
    expect(cart.comments.count).to eq 1
    expect(Approval.count).to eq 3
    expect(cart.approvals.count).to eq 3
    expect(cart.approvals.where(role: 'approver').count).to eq 2
    expect(cart.approvals.where(role: 'requester').count).to eq 1
    expect(cart.comments.first.comment_text).to eq "Hi, this is a comment from the first approval group, I hope it works!\r\nThis is the second line of the comment."
    expect(cart.comments.first.user_id).to eq cart.requester.id
    expect(cart.requester.email_address).to eq 'requester1@some-dot-gov.gov'

    post 'send_cart', @json_params_2

    expect(Cart.count).to eq 1
    cart = Cart.first
    expect(cart.cart_items.count).to eq 1
    expect(cart.cart_items[0].price).to eq 9.87
    expect(cart.approval_group.name).to eq "secondApprovalGroup"
    expect(cart.comments.count).to eq 2
    expect(cart.comments.last.comment_text).to eq "Hi, this is a comment from the second approval group, I hope it works!\r\nThis is the second line of the comment."
    expect(cart.requester.comments.first.comment_text).to eq "Hi, this is a comment from the second approval group, I hope it works!\r\nThis is the second line of the comment."
    expect(cart.approvals.count).to eq 1
    expect(cart.approvals.where(role: 'approver').count).to eq 0
    expect(cart.approvals.where(role: 'requester').count).to eq 1
    expect(cart.requester.email_address).to eq 'requester-approval-group2@some-dot-gov.gov'

  end

  context 'cart item traits' do
    it 'get added to the database correctly' do
      @json_params_1 = JSON.parse(params_request_1)

      expect(Cart.count).to eq 0

      post 'send_cart', @json_params_1
      expect(Cart.count).to eq 1
      cart = Cart.first
      expect(cart.cart_items.first.cart_item_traits.count).to eq 3
      expect(cart.cart_items.first.cart_item_traits[0].name).to eq "socio"
      expect(cart.cart_items.first.cart_item_traits[1].name).to eq "socio"
      expect(cart.cart_items.first.cart_item_traits[2].name).to eq "features"
      expect(cart.cart_items.first.cart_item_traits[0].value).to eq "s"
      expect(cart.cart_items.first.cart_item_traits[1].value).to eq "w"
      expect(cart.cart_items.first.cart_item_traits[2].value).to eq "bpa"
    end

    it 'get handled when not sent by the client' do
      @json_params_1 = JSON.parse(params_request_1)
      @json_params_1["cartItems"][0]["traits"] = nil

      post 'send_cart', @json_params_1
      expect(response.status).to eq 200
    end
  end

end
