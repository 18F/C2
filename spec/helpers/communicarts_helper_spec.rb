describe CommunicartsHelper do
  describe "#total_price_from_params" do
  let(:params) {

  '{
        "cartName": "",
        "cartNumber": "2867637",
        "category": "initiation",
        "email": "read.robert@gmail.com",
        "fromAddress": "",
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

    before do
      @json_params = JSON.parse(params)
    end

    it "should calculate a total price from the params" do
      expect(total_price_from_params(@json_params['cartItems'])).to eq 208.5
    end
  end
end