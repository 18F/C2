require 'spec_helper'

describe 'Creating a cart' do
  before do
    approval_group_1 = FactoryGirl.create(:approval_group_with_approvers, name: "firstApprovalGroup")
    # approval_group_1 = ApprovalGroup.create(name: "firstApprovalGroup")
    approval_group_2 = ApprovalGroup.create(name: "secondApprovalGroup")
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
      "initiationComment": "\r\n\r\nHi, this is a comment, I hope it works!\r\nThis is the second line of the comment.",
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

  it 'replaces existing cart items and approval group when initializing and existing cart' do
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

    post 'send_cart', @json_params_2

    cart = Cart.first
    expect(cart.cart_items.count).to eq 1
    expect(cart.cart_items[0].price).to eq 9.87
    expect(cart.approval_group.name).to eq "secondApprovalGroup"
    expect(cart.comments.first.comment_text).to eq "Hi, this is a comment, I hope it works!\r\nThis is the second line of the comment."
    expect(cart.comments.count).to eq 1
    expect(cart.approvals.count).to eq 2
  end

  it 'handles an email recipient sent in request'

  it 'handles non-existent approval groups'

  it 'traits get added to the database correct' do
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
end
