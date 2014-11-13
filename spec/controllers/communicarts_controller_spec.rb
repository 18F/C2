require 'spec_helper'

describe CommunicartsController do

  let(:params) {

  '{
      "cartName": "",
      "cartNumber": "2867637",
      "category": "initiation",
      "email": "test-email@some-dot-gov.gov",
      "fromAddress": "from-address@some-dot-gov.gov",
      "toAddress": ["to-address@some-dot-gov.gov"],
      "gsaUserName": "",
      "initiationComment": "\r\n\r\nHi, this is a comment, I hope it works!\r\nThis is the second line of the comment.",
      "properties": {
        "origin":"navigator"
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
      allow(controller).to receive(:total_price_from_params)
    end

    context 'approval group' do
      before do
        allow(CommunicartMailer).to receive_message_chain(:cart_notification_email, :deliver)
      end

      context 'is indicated' do
        before do
          approval_group
          @json_params['approvalGroup'] = "anotherApprovalGroupName"
        end

        it 'uses an existing approval group' do
          expect(ApprovalGroup).to receive(:find_by_name).with("anotherApprovalGroupName").and_return(approval_group)
          post 'send_cart', @json_params
        end

        it 'invokes a mailer' do
          mock_mailer = double
          expect(CommunicartMailer).to receive(:cart_notification_email).and_return(mock_mailer)
          expect(mock_mailer).to receive(:deliver)
          post 'send_cart', @json_params
        end

        it 'creates a comment given a comment param' do
          mock_comment = mock_model(Comment)
          allow(mock_comment).to receive(:[]=)
          allow(mock_comment).to receive(:has_attribute?).with('commentable_id').and_return(true)
          allow(mock_comment).to receive(:save)

          expect(Comment).to receive(:create!).with(user_id: approval_group.requester_id, comment_text: "Hi, this is a comment, I hope it works!\r\nThis is the second line of the comment.").and_return(mock_comment)
          post 'send_cart', @json_params
        end

        it 'does not create a comment when not given a comment param' do
          expect(Comment).not_to receive(:create)
          @json_params['initiationComment'] = ''
          post 'send_cart', @json_params
        end

      end

      context "CORS requests" do
        it "should set the Access-Control-Allow-Origin header to allow CORS from anywhere" do
          post 'send_cart', @json_params
          response.headers['Access-Control-Allow-Origin'].should == '*'
        end

        it "should allow general HTTP methods thru CORS (GET/POST/PUT)" do
          post 'send_cart', @json_params
          allowed_http_methods = response.header['Access-Control-Allow-Methods']
          %w{GET POST PUT}.each do |method|
            allowed_http_methods.should include(method)
          end
        end
      end

    end

    context 'template rendering' do
      it 'renders a navigation template' do
        approval_group
        post 'send_cart', @json_params
        expect(response).to render_template(partial: '_navigator_cart')
      end

      it 'renders the default template' do
        approval_group
        @json_params['properties'] = {}
        post 'send_cart', @json_params
        expect(response).to render_template(partial: '_cart')
      end

    end

    context 'method return' do
      it 'returns 201' do
        approval_group
        post 'send_cart', @json_params
        expect(response.status).to eq(201)
      end

      it 'returns cart as json' do
        approval_group
        post 'send_cart', @json_params
        json_response = JSON.parse(response.body)
        expect(json_response["name"]).to eq("2867637")
        expect(json_response["cart_items"][0]["description"]).to eq("ROUND RING VIEW BINDER WITH INTERIOR POC")
        expect(json_response["cart_items"][1]["cart_item_traits"][0]["name"]).to eq("socio")
      end
    end

    context 'no approval_group is indicated' do
      #TODO: Write specs
    end

  end

  describe 'POST approval_reply_received' do
    let(:cart) { FactoryGirl.create(:cart_with_approval_group, external_id: 246810) }
    let(:approver) { FactoryGirl.create(:user) }
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

    let(:one_clickapproval_params) {
      '{
      "cch": "5a4b3c2d1e",
      "cart_id": "12345"
      "user_id": "54321",
      "action": "approve",
      "scope": "all"
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
        allow(User).to receive(:find_by).and_return(approver)
        allow(cart).to receive_message_chain(:approval_users, :where, :first).and_return(approver)
        approval.update_attributes(cart_id: cart.id, user_id: approver.id)
        allow(cart).to receive_message_chain(:approvals, :where).and_return([approval])
        allow(Cart).to receive_message_chain(:where, :where, :first).and_return(cart)

        # Remove stub to view email layout in development through letter_opener
        allow(CommunicartMailer).to receive_message_chain(:approval_reply_received_email, :deliver)
        allow(EmailStatusReport).to receive(:new)
        @json_approval_params = JSON.parse(approval_params)
      end

      it 'invokes a mailer' do
        allow(cart).to receive(:update_approval_status)
        mock_mailer = double

        expect(CommunicartMailer).to receive(:approval_reply_received_email).and_return(mock_mailer)
        expect(mock_mailer).to receive(:deliver)
        post 'approval_reply_received', @json_approval_params
      end

      it 'updates the cart status' do
        post 'approval_reply_received', @json_approval_params
      end

      it 'updates the approval status' do
        allow(approval_list).to receive(:count)
        allow(cart).to receive_message_chain(:approvals, :count)
        allow(cart).to receive(:update_approval_status)

        expect(approval).to receive(:update_attributes).with(status: 'approved')
        post 'approval_reply_received', @json_approval_params
      end

      it 'adds the comment' do
        allow(CommunicartMailer).to receive_message_chain(:approval_reply_received_email, :deliver)

        FactoryGirl.create(:approval, user_id: approver.id)
        @json_approval_params = JSON.parse(approval_params)
        @json_approval_params['fromAddress'] = approver.email_address

        allow(Cart).to receive_message_chain(:where, :where, :first).and_return(cart)
        allow(cart).to receive_message_chain(:approval_users, :where).and_return([approver])
        allow(cart).to receive_message_chain(:cart_approvals, :where)
        allow(cart).to receive(:update_approval_status)

        allow_any_instance_of(Approval).to receive(:update_attributes)

        expect{post 'approval_reply_received', @json_approval_params}.to change{Comment.count}.from(0).to(1)
      end

      it 'creates a comment given a comment param' do
        allow(Cart).to receive(:find_by).and_return(cart)
        allow(cart).to receive_message_chain(:approval_group, :approvers, :where).and_return([approver])
        allow(cart).to receive(:update_approval_status)

        mock_comment = mock_model(Comment)
        allow(mock_comment).to receive(:[]=)
        allow(mock_comment).to receive(:has_attribute?).with('commentable_id').and_return(true)
        allow(mock_comment).to receive(:save)
        expect(Comment).to receive(:new).with(user_id: approver.id, comment_text: 'Test Approval Comment').and_return(mock_comment)
        post 'approval_reply_received', @json_approval_params
      end

      it 'does not create a comment when not given a comment param' do
        approver.update_attributes(email_address: 'judy.jetson@spacelysprockets.com')
        FactoryGirl.create(:approval, user_id: approver.id)
        @json_approval_params = JSON.parse(approval_params)
        allow(Cart).to receive(:find_by).and_return(cart)
        allow(cart).to receive(:update_approval_status)
        @json_approval_params['comment'] = ''

        expect(Comment).not_to receive(:create)
        post 'approval_reply_received', @json_approval_params
      end

    end



    context 'rejected cart' do
      let(:rejected_cart) { FactoryGirl.create(:cart, external_id: 109876, name: 'Cart soon to be rejected') }
      let(:cart_item) {FactoryGirl.create(:cart_item)}

      before do
        rejected_cart.cart_items << cart_item
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
        UserRole.create!(user_id: requester.id, approval_group_id: rejection_approval_group.id, role: 'requester')
        Approval.create(user_id: requester.id, cart_id: rejected_cart.id, role: 'requester')
        rejected_cart.approvals << approval1
        rejected_cart.approvals << approval2
        rejected_cart.save

        allow(rejected_cart).to receive(:update_approval_status)
        @json_rejection_params = JSON.parse(rejection_params)
      end

      it 'sets the approval to rejected status' do
        #FIXME: grab the specific approval
        expect_any_instance_of(Approval).to receive(:update_attributes).with({status: 'rejected'})
        post 'approval_reply_received', @json_rejection_params
      end

      it 'sends out a reject status email to the approvers' do
        allow(Cart).to receive_message_chain(:where, :where, :first).and_return(rejected_cart)
        mock_mailer = double
        expect(CommunicartMailer).to receive(:rejection_update_email).exactly(2).times.and_return(mock_mailer)
        expect(mock_mailer).to receive(:deliver).exactly(2).times

        post 'approval_reply_received', @json_rejection_params
      end

      it 'creates another set of approvals when another cart request for that same cart is intiiated'

    end

  end

  describe 'PUT approval_response: Approving a cart through email endpoint' do
    let(:approval_params_with_token) {
      '{
      "cch": "5a4b3c2d1ee1d2c3b4a5",
      "cart_id": "246810",
      "user_id": "108642",
      "approver_action": "approve"
      }'
    }

    let(:token) { ApiToken.create!(user_id: 108642, cart_id: 246810, expires_at: Time.now + 5.days) }
    let(:cart) { FactoryGirl.create(:cart_with_approvals) }
    let(:approver) { FactoryGirl.create(:user, id: 108642, email_address: 'another_approver@some-dot-gov.gov') }

    before do
      @json_approval_params_with_token = JSON.parse(approval_params_with_token)
      allow(token).to receive(:user_id).and_return(108642)
      allow(token).to receive(:cart_id).and_return(246810)
      allow(Cart).to receive(:find_by).with(id: 246810).and_return(cart)
      Approval.last.update_attributes(user_id: 108642)
    end

    context 'valid params' do
      before do
        expect(ApiToken).to receive(:find_by).with(access_token: "5a4b3c2d1ee1d2c3b4a5").and_return(token)
      end

      it 'will be successful' do
        approver
        allow_any_instance_of(Approval).to receive(:update_attributes)
        put 'approval_response', @json_approval_params_with_token
        expect(response.status).to eq 200
      end

      it 'successfully validates the user_id and cart_id with the token' do
        approver
        allow_any_instance_of(Approval).to receive(:update_attributes)
        expect { put 'approval_response', @json_approval_params_with_token }.not_to raise_error
      end

    end

    context 'Request token' do
      it 'fails when the token does not exist' do
        @json_approval_params_with_token["cch"] = nil
        bypass_rescue
        expect { put 'approval_response', @json_approval_params_with_token }.to raise_error(AuthenticationError)
      end

      it 'fails when the token has expired' do
        token.update_attributes(expires_at: Time.now - 8.days)
        expect(ApiToken).to receive(:find_by).with(access_token: "5a4b3c2d1ee1d2c3b4a5").and_return(token)
        bypass_rescue
        expect { put 'approval_response', @json_approval_params_with_token }.to raise_error(AuthenticationError)
      end

      it 'fails when the token has already been used once' do
        token.update_attributes(used_at: Time.now - 1.hour)
        expect(ApiToken).to receive(:find_by).with(access_token: "5a4b3c2d1ee1d2c3b4a5").and_return(token)
        bypass_rescue
        expect { put 'approval_response', @json_approval_params_with_token }.to raise_error(AuthenticationError)
      end

      skip 'marks a token as used'
    end
  end

end
