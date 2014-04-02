require 'spec_helper'

describe 'CommunicartsController' do
  describe "POST /communicarts/send_cart" do
    it "makes a successful request" do

      params = {
        cartNumber: "2867637",
        category: "initiation",
        attention: "read.robert@gmail.com",
        fromAddress: "",
        gsaUserName: "",
        initiationComment: "\r\n\r\nHi, this is a comment, I hope it works!\r\nThis is the second line of the comment.",
        cart: [
          {
            vendor: "DOCUMENT IMAGING DIMENSIONS, INC.",
            description: "ROUND RING VIEW BINDER WITH INTERIOR POC",
            url: "/advantage/catalog/product_detail.do?&oid=704213980&baseOid=&bpaNumber=GS-02F-XA002",
            notes: "",
            qty: "24",
            details: "Direct Delivery 3-4 days delivered ARO",
            partNumber: "7510-01-519-4381",
            price: "$2.46"
            },
            {
              vendor: "OFFICE DEPOT",
              description: "PEN,ROLLER,GELINK,G-2,X-FINE",
              url: "/advantage/catalog/product_detail.do?&oid=703389586&baseOid=&bpaNumber=GS-02F-XA009",
              notes: "",
              qty: "5",
              details: "Direct Delivery 3-4 days delivered ARO",
              partNumber: "PIL31003",
              price: "$10.29"
              },
              {
                vendor: "METRO OFFICE PRODUCTS",
                description: "PAPER,LEDGER,11X8.5",
                url: "/advantage/catalog/product_detail.do?&oid=681115589&baseOid=&bpaNumber=GS-02F-XA004",
                notes: "",
                qty: "3",
                details: "Direct Delivery 3-4 days delivered ARO",
                partNumber: "WLJ90310",
                price: "$32.67"
              }
            ]
          }

      post "/send_cart", params
      expect(response.status).to eq 200
    end
  end
end
