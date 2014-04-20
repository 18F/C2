require 'spec_helper'

describe 'Creating a cart' do
  let(:params_request_1) {
  '{
      "cartName": "",
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
          ]
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
          "features": []
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
          "features": []
        }
      ]
    }'
  }

  let(:params_request_2) {
  '{
      "cartName": "",
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
          ]
        }
      ]
    }'
  }

  it 'replaces existing cart items when initializing and existing cart' do
    @json_params_1 = JSON.parse(params_request_1)
    @json_params_2 = JSON.parse(params_request_2)

    expect(Cart.count).to eq 0

    post 'send_cart', @json_params_1
    expect(Cart.count).to eq 1
    cart = Cart.first
    expect(cart.cart_items.count).to eq 3

    post 'send_cart', @json_params_2
    cart = Cart.first
    expect(cart.cart_items.count).to eq 1
  end
end