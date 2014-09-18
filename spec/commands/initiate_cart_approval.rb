require 'spec_helper'

describe 'Commands::Approval::InitiateCartApproval' do

  let(:cart) { double("cart").as_null_object }

  let(:params_request) {
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
        "something": "awesome",
        "another something": "awesome again"
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

          "features": [
              "sale"
          ]
        }
      ]
    }'
  }

  describe '#perform' do
    before do
      Cart.stub_chain(:initialize_cart_with_items, :reload, :decorate).and_return(cart)
    end

    context 'handling absence of approvalGroup' do
      { blank:"", nil: nil }.each do |key,val|
        it "bypasses processing the approval group with #{key} value" do
          command_params = JSON.parse(params_request)
          command_params["approvalGroup"] = val

          cart.should_receive(:process_approvals_without_approval_group).with(command_params)
          Commands::Approval::InitiateCartApproval.new.perform(command_params)
        end
      end
    end

    context 'handling the presence of approvalGroup' do
      context 'no existing approvals' do
        it "processes the approval group" do
          command_params = JSON.parse(params_request)
          command_params["approvalGroup"] = "someApprovalGroup"
          cart.stub_chain(:approvals, :any?).and_return false

          cart.should_receive(:process_approvals_from_approval_group)
          Commands::Approval::InitiateCartApproval.new.perform(command_params)
        end
      end

      context 'existing approvals' do
        it 'refrains from processing the approvals' do
          command_params = JSON.parse(params_request)
          command_params["approvalGroup"] = "someApprovalGroup"
          cart.stub_chain(:approvals, :any?).and_return true

          cart.should_not_receive(:process_approvals_from_approval_group)
          Commands::Approval::InitiateCartApproval.new.perform(command_params)
        end
      end
    end
  end
end
