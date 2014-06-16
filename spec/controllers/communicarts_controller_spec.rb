require 'spec_helper'

describe CommunicartsController do

  let(:params) {

  '{
        "cartName": "",
        "cartNumber": "2867637",
        "category": "initiation",
        "email": "test-email@some-dot-gov.gov",
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
            "traits": {
                "socio": [
                    "s",
                    "w"
                ],
                "features": [
                    "bpa"
                ],
                "green": "true"
            }
          },
          {
            "vendor": "OFFICE DEPOT",
            "description": "PEN,ROLLER,GELINK,G-2,X-FINE",
            "url": "/advantage/catalog/product_detail.do?&oid=703389586&baseOid=&bpaNumber=GS-02F-XA009",
            "notes": "",
            "qty": "5",
            "details": "Direct Delivery 3-4 days delivered ARO",
            "partNumber": "PIL31003",
            "price": "$10.29",
            "traits": {
                "socio": [
                    "s",
                    "w"
                ],
                "features": [
                    "bpa"
                ],
                "green": "true"
            }

          },
          {
            "vendor": "METRO OFFICE PRODUCTS",
            "description": "PAPER,LEDGER,11X8.5",
            "url": "/advantage/catalog/product_detail.do?&oid=681115589&baseOid=&bpaNumber=GS-02F-XA004",
            "notes": "",
            "qty": "3",
            "details": "Direct Delivery 3-4 days delivered ARO",
            "partNumber": "WLJ90310",
            "price": "$32.67",
            "traits": {
                "socio": [
                    "s",
                    "w"
                ],
                "features": [
                    "bpa"
                ],
                "green": "true"
            }
          }
        ]
      }'
    }

  let(:approval_group) { FactoryGirl.create(:approval_group_with_approvers_and_requester, name: "anotherApprovalGroupName") }
  let(:approval) { FactoryGirl.create(:approval) }
  let(:approval_list) { [approval] }

  describe 'POST send_cart' do
    before do
      @json_params = JSON.parse(params)
      controller.stub(:total_price_from_params)
    end

    context 'approval group' do
      before do
        CommunicartMailer.stub_chain(:cart_notification_email, :deliver)
      end

      context 'is indicated' do
        before do
          approval_group
          @json_params['approvalGroup'] = "anotherApprovalGroupName"
        end

        it 'uses an existing approval group' do
          ApprovalGroup.should_receive(:find_by_name).with("anotherApprovalGroupName").and_return(approval_group)
          post 'send_cart', @json_params
        end

        it 'invokes a mailer' do
          mock_mailer = double
          CommunicartMailer.should_receive(:cart_notification_email).and_return(mock_mailer)
          mock_mailer.should_receive(:deliver)
          post 'send_cart', @json_params
        end

        it 'creates a comment given a comment param' do
          Comment.should_receive(:create)
          post 'send_cart', @json_params
        end

        it 'does not create a comment when not given a comment param' do
          Comment.should_not receive(:create)
          @json_params['initiationComment'] = ''
          post 'send_cart', @json_params
        end

      end

      context 'is not indicated' do
        it "creates a new approval group based on the 'fromAddress' parameter sent" do
          ApprovalGroup.should_not_receive(:find_by_name)
          ApprovalGroup.should_receive(:create).with(
            {name: 'approval-group-2867637'}
            ).and_return(approval_group)

          @json_params['fromAddress'] = 'approver-address1234@some-dot-gov.gov'
          post 'send_cart', @json_params
        end

        it 'creates a comment given a comment param' do
          Comment.should_receive(:create)
          post 'send_cart', @json_params
        end

        it 'does not create a comment when not given a comment param' do
          Comment.should_not receive(:create)
          @json_params['initiationComment'] = ''
          post 'send_cart', @json_params
        end

      end
    end

    it 'sets totalPrice'

  end

  describe 'POST approval_reply_received' do
    let(:cart) { FactoryGirl.create(:cart_with_approval_group, external_id: 246810) }
    let(:approver) { FactoryGirl.create(:user, id: 1234) }
    let(:report) { EmailStatusReport.new(cart) }

    let(:approval_params) {
      '{
      "cartNumber": "246810",
      "category": "approvalreply",
      "attention": "",
      "fromAddress": "judy.jetson@spacelysprockets.com",
      "gsaUserName": "",
      "gsaUsername": null,
      "date": "Sun, 13 Apr 2014 18:06:15 -0400",
      "approve": "APPROVE",
      "disapprove": null,
      "comment": "Test Approval Comment"
      }'
    }

    let(:rejection_params) {
      '{
      "cartNumber": "109876",
      "category": "approvalreply",
      "attention": "",
      "fromAddress": "email1@some-dot-gov.gov",
      "gsaUserName": "",
      "gsaUsername": null,
      "date": "Sun, 13 Apr 2014 18:06:15 -0400",
      "approve": "",
      "disapprove": "REJECT"
      }'
    }

    #TODO: Replace approve/disapprove with generic action

    context 'approved cart' do
      before do
        User.stub(:find_by).and_return(approver)
        cart.stub_chain(:approval_users, :where, :first).and_return(approver)
        approval.update_attributes(user_id: 1234)
        cart.stub_chain(:approvals, :where).and_return([approval])
        Cart.stub_chain(:where, :where, :first).and_return(cart)

        # Remove stub to view email layout in development through letter_opener
        CommunicartMailer.stub_chain(:approval_reply_received_email, :deliver)
        EmailStatusReport.stub(:new)
        @json_approval_params = JSON.parse(approval_params)
      end

      it 'invokes a mailer' do
        cart.stub(:update_approval_status)
        mock_mailer = double

        CommunicartMailer.should_receive(:approval_reply_received_email).and_return(mock_mailer)
        mock_mailer.should_receive(:deliver)
        post 'approval_reply_received', @json_approval_params
      end

      it 'updates the cart status' do
        cart.should_receive(:update_approval_status)
        post 'approval_reply_received', @json_approval_params
      end

      it 'updates the approval status' do
        approval_list.stub(:count)
        cart.stub_chain(:approvals, :count)
        cart.stub(:update_approval_status)

        approval.should_receive(:update_attributes).with(status: 'approved')
        post 'approval_reply_received', @json_approval_params
      end

      it 'adds the comment' do
        CommunicartMailer.stub_chain(:approval_reply_received_email, :deliver)

        FactoryGirl.create(:approval, user_id: approver.id)
        @json_approval_params = JSON.parse(approval_params)
        @json_approval_params['fromAddress'] = approver.email_address

        Cart.stub_chain(:where, :where, :first).and_return(cart)
        cart.stub_chain(:approval_users, :where).and_return([approver])
        cart.stub_chain(:cart_approvals, :where)
        cart.stub(:update_approval_status)

        Approval.any_instance.stub(:update_attributes)

        ApproverComment.should_receive(:create).with(
          {comment_text: 'Test Approval Comment', user_id: approver.id}
              )
        post 'approval_reply_received', @json_approval_params
      end

      it 'creates a comment given a comment param' do
        Cart.stub(:find_by).and_return(cart)
        cart.stub_chain(:approval_group, :approvers, :where).and_return([approver])
        cart.stub(:update_approval_status)

        ApproverComment.should_receive(:create)
        post 'approval_reply_received', @json_approval_params
      end

      it 'does not create a comment when not given a comment param' do
        approver.update_attributes(email_address: 'judy.jetson@spacelysprockets.com')
        FactoryGirl.create(:approval, user_id: approver.id)
        @json_approval_params = JSON.parse(approval_params)
        Cart.stub(:find_by).and_return(cart)
        cart.stub(:update_approval_status)
        @json_approval_params['comment'] = ''

        Comment.should_not receive(:create)
        post 'approval_reply_received', @json_approval_params
      end

    end



    context 'rejected cart' do
      let(:rejected_cart) { FactoryGirl.create(:cart, external_id: 109876, name: 'Cart soon to be rejected') }

      before do
        rejection_approval_group = FactoryGirl.create(:approval_group, name: 'Test Approval Group 1')
        user1 = FactoryGirl.create(:user, email_address: 'email1@some-dot-gov.gov')
        user2 = FactoryGirl.create(:user, email_address: 'email2@some-dot-gov.gov')
        rejection_approval_group.user_roles << UserRole.create!(user_id: user1.id, approval_group_id: approval_group.id, role: 'approver')
        rejection_approval_group.user_roles << UserRole.create!(user_id: user2.id, approval_group_id: approval_group.id, role: 'approver')

        rejection_approval_group.save

        rejected_cart.approval_group = rejection_approval_group
        approval1 = Approval.create(user_id: user1.id, cart_id: rejected_cart.id, role: 'approver')
        approval2 = Approval.create(user_id: user2.id, cart_id: rejected_cart.id, role: 'approver')
        requester = FactoryGirl.create(:user, email_address: 'rejection-requester@some-dot-gov.gov')
        UserRole.create!(user_id: user1.id, approval_group_id: rejection_approval_group.id, role: 'requester')
        rejected_cart.approvals << approval1
        rejected_cart.approvals << approval2
        rejected_cart.save

        rejected_cart.stub(:update_approval_status)
        @json_rejection_params = JSON.parse(rejection_params)
      end

      it 'sets the approval to rejected status' do
        #FIXME: grab the specific approval
        Approval.any_instance.should_receive(:update_attributes).with({status: 'rejected'})
        post 'approval_reply_received', @json_rejection_params
      end

      it 'sends out a reject status email to the approvers' do
        Cart.stub_chain(:where, :where, :first).and_return(rejected_cart)
        mock_mailer = double
        CommunicartMailer.should_receive(:rejection_update_email).exactly(2).times.and_return(mock_mailer)
        mock_mailer.should_receive(:deliver).exactly(2).times

        post 'approval_reply_received', @json_rejection_params
      end

      it 'creates another set of approvals when another cart request for that same cart is intiiated'

    end

  end
end
