require 'spec_helper'

describe 'CommunicartsController' do
  describe "POST /communicarts/send_cart" do
    before do
      ENV.stub(:[])
      ENV.stub(:[]).with('NOTIFICATION_TO_EMAIL').and_return('george.jetson@spacelysprockets.com')

      params = CommunicartMailer.default_params.merge({from:'reply@communicart-stub.com'})
      CommunicartMailer.stub(:default_params).and_return(params)
      CommunicartsController.any_instance.stub(:total_price_from_params)
      CommunicartMailer.stub_chain(:cart_notification_email, :deliver)

      approval_group = FactoryGirl.create(:approval_group_with_approvers)
      ApprovalGroup.stub(:find_by).and_return(approval_group)
    end


    it "makes a successful request" do
      params = {
        cartName: "Q1 Test Cart",
        cartNumber: "2867637",
        category: "initiation",
        email: "read.robert@gmail.com",
        fromAddress: "",
        gsaUserName: "",
        initiationComment: "\r\n\r\nHi, this is a comment, I hope it works!\r\nThis is the second line of the comment.",
        approvalGroup: "MyApprovalGroup",
        cartItems: [
          {
            vendor: "DOCUMENT IMAGING DIMENSIONS, INC.",
            description: "ROUND RING VIEW BINDER WITH INTERIOR POC",
            url: "/advantage/catalog/product_detail.do?&oid=704213980&baseOid=&bpaNumber=GS-02F-XA002",
            notes: "",
            qty: "24",
            details: "Direct Delivery 3-4 days delivered ARO",
            socio: ["s","w"],
            partNumber: "7510-01-519-4381",
            price: "$2.46",
            features: []
          },
          {
            vendor: "OFFICE DEPOT",
            description: "PEN,ROLLER,GELINK,G-2,X-FINE",
            url: "/advantage/catalog/product_detail.do?&oid=703389586&baseOid=&bpaNumber=GS-02F-XA009",
            notes: "",
            qty: "5",
            details: "Direct Delivery 3-4 days delivered ARO",
            socio: [],
            partNumber: "PIL31003",
            price: "$10.29",
            features: []
          },
          {
            vendor: "METRO OFFICE PRODUCTS",
            description: "PAPER,LEDGER,11X8.5",
            url: "/advantage/catalog/product_detail.do?&oid=681115589&baseOid=&bpaNumber=GS-02F-XA004",
            notes: "",
            qty: "3",
            details: "Direct Delivery 3-4 days delivered ARO",
            socio: ["s"],
            partNumber: "WLJ90310",
            price: "$32.67",
            features: []
          }
        ]
      }

      post "/send_cart", params
      expect(response.status).to eq 200
    end

    it "invokes two email messages based on approval group" do

      params = {
        cartName: "Q1 Test Cart",
        cartNumber: "2867637",
        category: "initiation",
        email: "",
        approvalGroup: "MyApprovalGroup",
        fromAddress: "",
        gsaUserName: "",
        initiationComment: "\r\n\r\nHi, this is a comment, I hope it works!\r\nThis is the second line of the comment.",
        cartItems: [
          {
            vendor: "DOCUMENT IMAGING DIMENSIONS, INC.",
            description: "ROUND RING VIEW BINDER WITH INTERIOR POC",
            url: "/advantage/catalog/product_detail.do?&oid=704213980&baseOid=&bpaNumber=GS-02F-XA002",
            notes: "",
            qty: "24",
            details: "Direct Delivery 3-4 days delivered ARO",
            socio: ["s","w"],
            partNumber: "7510-01-519-4381",
            price: "$2.46",
            features: []
          },
          {
            vendor: "OFFICE DEPOT",
            description: "PEN,ROLLER,GELINK,G-2,X-FINE",
            url: "/advantage/catalog/product_detail.do?&oid=703389586&baseOid=&bpaNumber=GS-02F-XA009",
            notes: "",
            qty: "5",
            details: "Direct Delivery 3-4 days delivered ARO",
            socio: [],
            partNumber: "PIL31003",
            price: "$10.29",
            features: []
          },
          {
            vendor: "METRO OFFICE PRODUCTS",
            description: "PAPER,LEDGER,11X8.5",
            url: "/advantage/catalog/product_detail.do?&oid=681115589&baseOid=&bpaNumber=GS-02F-XA004",
            notes: "",
            qty: "3",
            details: "Direct Delivery 3-4 days delivered ARO",
            socio: ["s"],
            partNumber: "WLJ90310",
            price: "$32.67",
            features: []
          }
        ]
      }

      post "/send_cart", params
      expect(response.status).to eq 200
    end
  end

end
