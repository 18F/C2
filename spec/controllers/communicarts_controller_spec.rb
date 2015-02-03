describe CommunicartsController do
  let(:params) { read_fixture('cart_without_approval_group') }

  let(:approval_group) { FactoryGirl.create(:approval_group_with_approvers_and_requester, name: "anotherApprovalGroupName") }
  let(:approval) { FactoryGirl.create(:approval) }
  let(:approval_list) { [approval] }

  describe 'POST send_cart' do
    let(:json_params) { JSON.parse(params) }

    context 'approval group' do
      before do
        expect(Dispatcher).to receive(:deliver_new_cart_emails)
      end

      context 'is indicated' do
        before do
          approval_group
          json_params['approvalGroup'] = "anotherApprovalGroupName"
        end

        it 'uses an existing approval group' do
          expect(ApprovalGroup).to receive(:find_by_name).with("anotherApprovalGroupName").and_return(approval_group)
          post 'send_cart', json_params
        end

        it 'creates a comment given a comment param' do
          post 'send_cart', json_params

          comment = Comment.last
          expect(comment.user_id).to eq(approval_group.requester_id)
          expect(comment.comment_text).to eq("Hi, this is a comment, I hope it works!\r\nThis is the second line of the comment.")
        end

        it 'does not create a comment when not given a comment param' do
          expect(Comment).not_to receive(:create)
          json_params['initiationComment'] = ''
          post 'send_cart', json_params
        end

      end
    end

    context 'template rendering' do
      it 'renders a navigation template' do
        approval_group
        post 'send_cart', json_params
        expect(response).to render_template(partial: '_navigator_cart')
      end

      it 'renders the default template' do
        approval_group
        json_params['properties'] = {}
        post 'send_cart', json_params
        expect(response).to render_template(partial: '_cart_mail')
      end

    end

    context 'method return' do
      it 'returns 201' do
        approval_group
        post 'send_cart', json_params
        expect(response.status).to eq(201)
      end

      it 'returns cart as json' do
        approval_group
        post 'send_cart', json_params
        json_response = JSON.parse(response.body)
        expect(json_response["name"]).to eq("2867637")
        expect(json_response["cart_items"][0]["description"]).to eq("ROUND RING VIEW BINDER WITH INTERIOR POC")
        expect(json_response["cart_items"][1]["cart_item_traits"][0]["name"]).to eq("socio")
      end
    end

    context 'no approval_group is indicated' do
      #TODO: Write specs
    end

    context 'nonexistent approval_group is specified' do
      it 'should return 400 error' do
        json_params['approvalGroup'] = "nogrouphere"
        post  'send_cart', json_params
        expect(response.status).to eq(400)
        bod = JSON.parse response.body
        expect(JSON.parse(response.body)['message']).to eq("Approval Group Not Found")
      end
    end

  end

  describe 'POST approval_reply_received' do
    let(:cart) { FactoryGirl.create(:cart_with_approval_group, external_id: 246810) }
    let(:approver) { FactoryGirl.create(:user) }

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
        expect(User).to receive(:find_by).and_return(approver).at_least(:once) # TODO only once
        expect(cart).to receive_message_chain(:approval_users, :where, :first).and_return(approver)
        approval.update_attributes(cart_id: cart.id, user_id: approver.id)
        expect(cart).to receive_message_chain(:approvals, :where).and_return([approval])
        expect(Cart).to receive_message_chain(:where, :where, :first).and_return(cart)
        expect(CommunicartMailer).to receive_message_chain(:approval_reply_received_email, :deliver)

        @json_approval_params = JSON.parse(approval_params)
      end

      it 'updates the cart status' do
        post 'approval_reply_received', @json_approval_params
      end

      it 'updates the approval status' do
        expect(approval).to receive(:update_attributes).with(status: 'approved')
        post 'approval_reply_received', @json_approval_params
      end

      it 'adds the comment' do
        FactoryGirl.create(:approval, user_id: approver.id)
        @json_approval_params = JSON.parse(approval_params)
        @json_approval_params['fromAddress'] = approver.email_address

        expect {
          post 'approval_reply_received', @json_approval_params
        }.to change{ Comment.count }.from(0).to(1)
      end

      it 'creates a comment given a comment param' do
        expect {
          post 'approval_reply_received', @json_approval_params
        }.to change { Comment.count }.from(0).to(1)

        comment = Comment.last
        expect(comment.user_id).to eq(approver.id)
        expect(comment.comment_text).to eq('Test Approval Comment')
      end

      it 'does not create a comment when not given a comment param' do
        approver.update_attributes(email_address: 'judy.jetson@spacelysprockets.com')
        FactoryGirl.create(:approval, user_id: approver.id)
        @json_approval_params = JSON.parse(approval_params)
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
        approval1 = Approval.create!(user_id: user1.id, cart_id: rejected_cart.id, role: 'approver')
        approval2 = Approval.create!(user_id: user2.id, cart_id: rejected_cart.id, role: 'approver')
        requester = FactoryGirl.create(:user, email_address: 'rejection-requester@some-dot-gov.gov')
        UserRole.create!(user_id: requester.id, approval_group_id: rejection_approval_group.id, role: 'requester')
        Approval.create!(user_id: requester.id, cart_id: rejected_cart.id, role: 'requester')
        rejected_cart.approvals << approval1
        rejected_cart.approvals << approval2
        rejected_cart.save

        @json_rejection_params = JSON.parse(rejection_params)
      end

      it 'sets the approval to rejected status' do
        #FIXME: grab the specific approval
        expect_any_instance_of(Approval).to receive(:update_attributes).with({status: 'rejected'})
        post 'approval_reply_received', @json_rejection_params
      end

      it "sends a rejection notice to the requester" do
        post 'approval_reply_received', @json_rejection_params

        deliveries = ActionMailer::Base.deliveries
        expect(deliveries.size).to eq(1)
        mail = deliveries.last
        expect(mail.to).to eq([rejected_cart.requester.email_address])
        from_address = @json_rejection_params['fromAddress']
        expect(mail.html_part.to_s).to include("The approver, #{from_address}, rejected")
      end

      it "sends out a reject status email to the approvers"

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
    let!(:cart) { FactoryGirl.create(:cart_with_approvals, id: 246810) }
    let(:approver) { FactoryGirl.create(:user, id: 108642, email_address: 'another_approver@some-dot-gov.gov') }

    before do
      @json_approval_params_with_token = JSON.parse(approval_params_with_token)
      Approval.last.update_attributes(user_id: 108642)
    end

    context 'valid params' do
      before do
        expect(ApiToken).to receive(:find_by).with(access_token: "5a4b3c2d1ee1d2c3b4a5").and_return(token)
      end

      it 'will be successful' do
        approver
        expect_any_instance_of(Approval).to receive(:update_attributes)
        put 'approval_response', @json_approval_params_with_token
        expect(response.status).to eq 200
      end

      it 'successfully validates the user_id and cart_id with the token' do
        approver
        expect_any_instance_of(Approval).to receive(:update_attributes)
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

      it 'marks a token as used' do
        expect(ApiToken).to receive(:find_by).with(access_token: "5a4b3c2d1ee1d2c3b4a5").and_return(token)
        expect_any_instance_of(Approval).to receive(:update_attributes)
        approver

        put 'approval_response', @json_approval_params_with_token

        expect(response.status).to eq(200)
        token.reload
        expect(token.used_at).to_not eq(nil)
      end
    end
  end

end
