describe CommunicartsController do
  describe 'POST send_cart' do
    let(:params) { read_fixture('cart_without_approval_group') }
    let(:json_params) { JSON.parse(params) }

    let(:approval_group) { FactoryGirl.create(:approval_group_with_approvers_and_requester, name: "anotherApprovalGroupName") }

    context 'approval group is indicated' do
      before do
        expect(Dispatcher).to receive(:deliver_new_cart_emails)
        approval_group # create
        json_params['approvalGroup'] = "anotherApprovalGroupName"
      end

      it 'uses an existing approval group' do
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

    context 'template rendering' do
      before do
        approval_group # create
      end

      it 'renders a navigation template' do
        post 'send_cart', json_params
        expect(response).to render_template(partial: '_navigator_cart')
      end

      it 'renders the default template' do
        json_params['properties'] = {}
        post 'send_cart', json_params
        expect(response).to render_template(partial: '_cart_mail')
      end
    end

    context 'method return' do
      before do
        approval_group # create
      end

      it 'returns 201' do
        post 'send_cart', json_params
        expect(response.status).to eq(201)
      end

      it 'returns cart as json' do
        post 'send_cart', json_params
        json_response = JSON.parse(response.body)
        expect(json_response["name"]).to eq("2867637")
        expect(json_response["cart_items"][0]["description"]).to eq("ROUND RING VIEW BINDER WITH INTERIOR POC")
        expect(json_response["cart_items"][1]["cart_item_traits"][0]["name"]).to eq("socio")
      end
    end

    skip 'no approval_group is indicated'

    context 'nonexistent approval_group is specified' do
      it 'should return 400 error' do
        json_params['approvalGroup'] = "nogrouphere"
        post  'send_cart', json_params
        expect(response.status).to eq(400)
        data = JSON.parse(response.body)
        expect(data['message']).to eq("Approval Group Not Found")
      end
    end
  end

  describe 'POST approval_reply_received' do
    let(:cart) { FactoryGirl.create(:cart_with_approvals, external_id: 246810) }
    let(:approval) { cart.approver_approvals.first }
    let(:approver) { approval.user }

    let(:params) {
      {
        cartNumber: cart.external_id,
        category: 'approvalreply',
        attention: '',
        fromAddress: approver.email_address,
        gsaUserName: '',
        gsaUsername: nil,
        date: 'Sun, 13 Apr 2014 18:06:15 -0400',
        approve: 'APPROVE',
        disapprove: nil,
        comment: 'Test Approval Comment'
      }.with_indifferent_access
    }

    #TODO: Replace approve/disapprove with generic action

    context 'approved cart' do
      before do
        expect(CommunicartMailer).to receive_message_chain(:approval_reply_received_email, :deliver)
      end

      it 'updates the cart status' do
        post 'approval_reply_received', params
      end

      it 'updates the approval status' do
        post 'approval_reply_received', params
        approval.reload
        expect(approval).to be_approved
      end

      it 'adds the comment' do
        params['fromAddress'] = approver.email_address

        expect {
          post 'approval_reply_received', params
        }.to change{ Comment.count }.from(0).to(1)
      end

      it 'creates a comment given a comment param' do
        expect {
          post 'approval_reply_received', params
        }.to change { Comment.count }.from(0).to(1)

        comment = Comment.last
        expect(comment.user_id).to eq(approver.id)
        expect(comment.comment_text).to eq('Test Approval Comment')
      end

      it 'does not create a comment when not given a comment param' do
        params['comment'] = ''
        expect(Comment).not_to receive(:create)
        post 'approval_reply_received', params
      end
    end



    context 'rejected cart' do
      before do
        params[:approve] = ''
        params[:disapprove] = 'REJECT'
      end

      it 'sets the approval to rejected status' do
        post 'approval_reply_received', params
        approval.reload
        expect(approval).to be_rejected
      end

      it "sends a rejection notice to the requester" do
        post 'approval_reply_received', params

        deliveries = ActionMailer::Base.deliveries
        expect(deliveries.size).to eq(1)
        mail = deliveries.last
        expect(mail.to).to eq([cart.requester.email_address])
        from_address = params['fromAddress']
        expect(mail.html_part.to_s).to include("The approver, #{from_address}, rejected")
      end

      it "sends out a reject status email to the approvers"

      it 'creates another set of approvals when another cart request for that same cart is intiiated'

    end

  end

  describe 'PUT approval_response: Approving a cart through email endpoint' do
    let!(:cart) { FactoryGirl.create(:cart_with_approvals) }
    let!(:approval) { cart.approver_approvals.first }
    let!(:approver) { approval.user }
    let!(:token) { approval.create_api_token! }

    let(:approval_params_with_token) {
      {
        cch: token.access_token,
        cart_id: cart.id.to_s,
        user_id: approver.id.to_s,
        approver_action: 'approve'
      }.with_indifferent_access
    }

    context 'valid params' do
      it 'will be successful' do
        put 'approval_response', approval_params_with_token
        approval.reload
        expect(approval).to be_approved
        expect(response).to redirect_to(cart_path(cart))
      end

      it 'successfully validates the user_id and cart_id with the token' do
        expect { put 'approval_response', approval_params_with_token }.not_to raise_error
      end

      it "signs the user in" do
        put 'approval_response', approval_params_with_token
        expect(controller.send(:signed_in?)).to eq(true)
      end
    end

    context 'Request token' do
      it 'fails when the token does not exist' do
        approval_params_with_token[:cch] = nil
        bypass_rescue
        expect { put 'approval_response', approval_params_with_token }.to raise_error(AuthenticationError)
      end

      it 'fails when the token has expired' do
        token.update_attributes(expires_at: Time.now - 8.days)
        bypass_rescue
        expect { put 'approval_response', approval_params_with_token }.to raise_error(AuthenticationError)
      end

      it 'fails when the token has already been used once' do
        token.update_attributes(used_at: Time.now - 1.hour)
        bypass_rescue
        expect { put 'approval_response', approval_params_with_token }.to raise_error(AuthenticationError)
      end

      it 'marks a token as used' do
        put 'approval_response', approval_params_with_token

        approval.reload
        expect(approval).to be_approved
        expect(response).to redirect_to(cart_path(cart))
        token.reload
        expect(token.used_at).to_not eq(nil)
      end
    end
  end

end
