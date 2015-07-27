describe ProposalsController do
  include ReturnToHelper
  let(:user) { FactoryGirl.create(:user) }

  describe '#index' do
    before do
      login_as(user)
    end

    it 'sets data fields' do
      proposal1 = FactoryGirl.create(:proposal, requester: user)
      proposal2 = FactoryGirl.create(:proposal)
      proposal2.approvals.create!(user: user, status: 'actionable')

      get :index
      expect(assigns(:pending_data).rows.sort).to eq [proposal1, proposal2]
      expect(assigns(:approved_data).rows.sort).to be_empty
      expect(assigns(:cancelled_data).rows.sort).to be_empty
    end
  end

  describe '#archive' do
    before do
      login_as(user)
    end

    it 'should show all the closed proposals' do
      2.times.map do |i|
        FactoryGirl.create(:proposal, requester: user, status: 'approved')
      end
      FactoryGirl.create(:proposal, requester: user)

      get :archive

      expect(assigns(:proposals_data).rows.size).to eq(2)
    end
  end

  describe '#show' do
    before do
      login_as(user)
    end

    context 'visitors' do
      it 'should allow the requester to see it' do
        proposal = FactoryGirl.create(:proposal, requester: user)
        get :show, id: proposal.id
        expect(response).not_to redirect_to("/proposals/")
        expect(flash[:alert]).not_to be_present
      end

      it 'should redirect random users' do
        proposal = FactoryGirl.create(:proposal)
        get :show, id: proposal.id
        expect(response).to redirect_to(proposals_path)
        expect(flash[:alert]).to be_present
      end
    end

    context 'admins' do
      after do
        ENV['ADMIN_EMAILS'] = ""
        ENV['CLIENT_ADMIN_EMAILS'] = ""
      end

      it "allows admins to view requests of same client" do
        #Set up a temporary class
        module SomeCompany
          class SomethingApprovable
          end
        end

        ENV['CLIENT_ADMIN_EMAILS'] = "#{user.email_address}"
        proposal = FactoryGirl.create(:proposal, requester_id: 5555, client_data_type:"SomeCompany::SomethingApprovable")
        user.update_attributes(client_slug: 'some_company')

        get :show, id: proposal.id
        expect(response).not_to redirect_to(proposals_path)
        expect(response.request.fullpath).to eq(proposal_path proposal.id)
      end

      it "allows app admins to view requests outside of related client" do
        proposal = FactoryGirl.create(:proposal, requester_id: 5555, client_data_type:"SomeCompany::SomethingApprovable")
        user.update_attributes(client_slug: 'some_other_company')
        ENV['ADMIN_EMAILS'] = "#{user.email_address}"

        get :show, id: proposal.id
        expect(response).not_to redirect_to(proposals_path)
        expect(response.request.fullpath).to eq(proposal_path proposal.id)
      end
    end

  end

  describe '#query' do
    let!(:proposal) { FactoryGirl.create(:proposal, requester: user) }
    before do
      login_as(user)
    end

    it 'should only include proposals user is a part of' do
      get :query
      expect(assigns(:proposals_data).rows).to eq([proposal])
    end

    it 'should filter results by date range' do
      past_proposal = FactoryGirl.create(
        :proposal, created_at: Date.new(2012, 5, 6), requester: user)
      get :query
      expect(assigns(:proposals_data).rows).to eq([proposal, past_proposal])

      get :query, start_date: '2012-05-04', end_date: '2012-05-07'
      expect(assigns(:proposals_data).rows).to eq([past_proposal])

      get :query, start_date: '2012-05-04', end_date: '2012-05-06'
      expect(assigns(:proposals_data).rows).to eq([])
    end

    it 'ignores bad input' do
      get :query, start_date: 'dasdas'
      expect(assigns(:proposals_data).rows).to eq([proposal])
    end

    context "#datespan_header" do
      render_views

      it 'has a nice header for month spans' do
        get :query, start_date: '2012-05-01', end_date: '2012-06-01'
        expect(response.body).to include("May 2012")
      end

      it 'has a generic header for other dates' do
        get :query, start_date: '2012-05-02', end_date: '2012-06-02'
        expect(response.body).to include("2012-05-02 - 2012-06-02")
      end
    end
  end

  describe '#cancel_form' do
    let(:proposal) { FactoryGirl.create(:proposal) }

    it 'should allow the requester to see it' do
      login_as(user)
      proposal.update_attributes(requester_id: user.id)

      get :show, id: proposal.id
      expect(response).not_to redirect_to("/proposals/")
      expect(flash[:alert]).not_to be_present
    end

    it 'should redirect random users' do
      login_as(user)
      get :cancel_form, id: proposal.id
      expect(response).to redirect_to(proposal_path)
      expect(flash[:alert]).to eq 'You are not the requester'
    end

    it 'should redirect for cancelled requests' do
      proposal.update_attributes(status:'cancelled')
      login_as(proposal.requester)

      get :cancel_form, id: proposal.id
      expect(response).to redirect_to(proposal_path proposal.id)
      expect(flash[:alert]).to eq 'Sorry, this proposal has been cancelled.'
    end
  end

  describe "#cancel" do
    let!(:proposal) { FactoryGirl.create(:proposal, requester: user) }

    before do
      login_as(user)
    end

    it 'sends a cancellation email' do
      mock_dispatcher = double('dispatcher').as_null_object
      allow(Dispatcher).to receive(:new).and_return(mock_dispatcher)
      expect(mock_dispatcher).to receive(:deliver_cancellation_emails)

      post :cancel, id: proposal.id, reason_input:'My test cancellation text'
    end
  end

  describe '#approve' do
    it "signs the user in via the token" do
      proposal = FactoryGirl.create(:proposal, :with_approver)
      approval = proposal.approvals.first
      token = approval.create_api_token!

      post :approve, id: proposal.id, cch: token.access_token

      expect(controller.send(:current_user)).to eq(approval.user)
    end

    it "won't sign the user in via the token if delegated" do
      proposal = FactoryGirl.create(:proposal, :with_approver)
      approval = proposal.approvals.first
      token = approval.create_api_token!
      approval.user.add_delegate(FactoryGirl.create(:user))

      post :approve, id: proposal.id, cch: token.access_token

      # TODO simplify this check
      expect(response).to redirect_to(root_path(return_to: self.make_return_to("Previous", request.fullpath)))
    end

    it "won't allow a missing token when using GET" do
      proposal = FactoryGirl.create(:proposal, :with_approver)
      login_as(proposal.approvers.first)

      get :approve, id: proposal.id

      expect(response).to have_http_status(403)
    end

    it "will allow action if the token is valid" do
      proposal = FactoryGirl.create(:proposal, :with_approver)
      approval = proposal.approvals.first
      token = approval.create_api_token!

      get :approve, id: proposal.id, cch: token.access_token

      approval.reload
      expect(approval.approved?).to be(true)
    end

    it "doesn't allow a token to be reused" do
      proposal = FactoryGirl.create(:proposal, :with_approver)
      approval = proposal.approvals.first
      token = approval.create_api_token!
      token.use!

      get :approve, id: proposal.id, cch: token.access_token

      expect(flash[:alert]).to include("Please sign in")
    end

    it "won't allow the approval to be approved twice through the web ui" do
      proposal = FactoryGirl.create(:proposal, :with_approver)
      login_as(proposal.approvers.first)

      post :approve, id: proposal.id

      expect(proposal.reload.approved?).to be true
      expect(flash[:success]).not_to be_nil
      expect(flash[:alert]).to be_nil

      flash.clear
      post :approve, id: proposal.id

      expect(flash[:success]).to be_nil
      expect(flash[:alert]).not_to be_nil
    end

    it "won't allow different delegates to approve" do
      proposal = FactoryGirl.create(:proposal, :with_approver)
      delegate1, delegate2 = FactoryGirl.create(:user), FactoryGirl.create(:user)
      mailbox = proposal.approvers.first
      mailbox.add_delegate(delegate1)
      mailbox.add_delegate(delegate2)
      login_as(delegate1)

      post :approve, id: proposal.id

      expect(flash[:success]).not_to be_nil
      expect(flash[:alert]).to be_nil

      flash.clear
      login_as(delegate2)
      post :approve, id: proposal.id

      expect(flash[:success]).to be_nil
      expect(flash[:alert]).not_to be_nil
    end

    it "allows a delegate to approve via the web UI" do
      proposal = FactoryGirl.create(:proposal, :with_serial_approvers)
      mailbox = proposal.approvers.second
      delegate = FactoryGirl.create(:user)
      mailbox.add_delegate(delegate)
      proposal.approvals.first.approve!
      login_as(delegate)

      post :approve, id: proposal.id

      expect(flash[:success]).not_to be_nil
      expect(flash[:alert]).to be_nil
      expect(proposal.reload.approved?).to be true
    end
  end
end
