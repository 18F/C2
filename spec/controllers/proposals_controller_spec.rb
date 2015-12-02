describe ProposalsController do
  include ReturnToHelper
  let(:user) { create(:user) }

  describe '#index' do
    before do
      login_as(user)
    end

    it 'sets data fields' do
      proposal1 = create(:proposal, requester: user)
      proposal2 = create(:proposal, :with_approver, approver_user: user)

      get :index
      expect(assigns(:pending_review_data).rows.sort).to eq [proposal2]
      expect(assigns(:pending_data).rows.sort).to eq [proposal1]
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
        create(:proposal, requester: user, status: 'approved')
      end
      create(:proposal, requester: user)

      get :archive

      expect(assigns(:proposals_data).rows.size).to eq(2)
    end

    context 'smoke test' do
      render_views

      it 'does not explode' do
        get :archive
      end
    end
  end

  describe '#show' do
    before do
      login_as(user)
    end

    context 'visitors' do
      it 'should allow the requester to see it' do
        proposal = create(:proposal, requester: user)
        get :show, id: proposal.id
        expect(response.status).to eq(200)
        expect(response).not_to redirect_to("/proposals/")
        expect(flash[:alert]).not_to be_present
      end

      it "treats non-subscriber users as un-authorized" do
        proposal = create(:proposal)
        get :show, id: proposal.id
        expect(response.status).to eq(403)
      end
    end

    context 'admins' do
      let(:requester) { create(:user) }
      let(:proposal) { create(:proposal, requester_id: requester.id, client_data_type: 'SomeCompany::SomethingApprovable') }

      before do
        allow(Proposal).to receive(:client_model_names).and_return(['SomeCompany::SomethingApprovable'])
        allow(Proposal).to receive(:client_slugs).and_return(%w(some_company some_other_company ncr))
      end

      it "allows admins to view requests of same client" do
        user.add_role('client_admin')
        user.update_attributes!(client_slug: 'some_company')

        get :show, id: proposal.id
        expect(response).not_to redirect_to(proposals_path)
        expect(response.request.fullpath).to eq(proposal_path proposal.id)
      end

      it "allows app admins to view requests outside of related client" do
        user.update_attributes!(client_slug: 'some_other_company')
        user.add_role('admin')

        get :show, id: proposal.id
        expect(response).not_to redirect_to(proposals_path)
        expect(response.request.fullpath).to eq(proposal_path proposal.id)
      end
    end

  end

  describe '#query' do
    let!(:proposal) { create(:proposal, requester: user) }
    before do
      login_as(user)
    end

    it 'should only include proposals user is a part of' do
      get :query
      expect(assigns(:proposals_data).rows).to eq([proposal])
    end

    it 'should filter results by date range' do
      prev_zone = Time.zone
      Time.zone = 'UTC'
      past_proposal = create(
        :proposal, created_at: Time.zone.local(2012, 5, 6), requester: user)
      get :query
      expect(assigns(:proposals_data).rows).to eq([proposal, past_proposal])

      get :query, start_date: '2012-05-04', end_date: '2012-05-07'
      expect(assigns(:proposals_data).rows).to eq([past_proposal])

      get :query, start_date: '2012-05-04', end_date: '2012-05-06'
      expect(assigns(:proposals_data).rows).to eq([])
      Time.zone = prev_zone
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

    context 'search' do
      it 'plays nicely with TabularData' do
        double, single, triple = 3.times.map { create(:proposal, requester: user) }
        double.update(public_id: 'AAA AAA')
        single.update(public_id: 'AAA')
        triple.update(public_id: 'AAA AAA AAA')

        get :query, text: "AAA"
        query = assigns(:proposals_data).rows

        expect(query.length).to be(3)
        expect(query[0].id).to be(triple.id)
        expect(query[1].id).to be(double.id)
        expect(query[2].id).to be(single.id)
      end
    end
  end

  describe '#cancel_form' do
    let(:proposal) { create(:proposal) }

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
    let!(:proposal) { create(:proposal, requester: user) }

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
      proposal = create(:proposal, :with_approver)
      approval = proposal.individual_steps.first
      token = create(:api_token, step: approval)

      post :approve, id: proposal.id, cch: token.access_token

      expect(controller.send(:current_user)).to eq(approval.user)
    end

    it "won't sign the user in via the token if delegated" do
      proposal = create(:proposal, :with_approver)
      approval = proposal.individual_steps.first
      token = create(:api_token, step: approval)
      approval.user.add_delegate(create(:user))

      post :approve, id: proposal.id, cch: token.access_token

      # TODO simplify this check
      expect(response).to redirect_to(root_path(return_to: self.make_return_to("Previous", request.fullpath)))
    end

    it "won't allow a missing token when using GET" do
      proposal = create(:proposal, :with_approver)
      login_as(proposal.approvers.first)

      get :approve, id: proposal.id

      expect(response).to have_http_status(403)
    end

    it "will allow action if the token is valid" do
      proposal = create(:proposal, :with_approver)
      approval = proposal.individual_steps.first
      token = create(:api_token, step: approval)

      get :approve, id: proposal.id, cch: token.access_token

      approval.reload
      expect(approval.approved?).to be(true)
    end

    it "doesn't allow a token to be reused" do
      proposal = create(:proposal, :with_approver)
      approval = proposal.individual_steps.first
      token = create(:api_token, step: approval)
      token.use!

      get :approve, id: proposal.id, cch: token.access_token

      expect(flash[:alert]).to include("Please sign in")
    end

    it "won't allow the approval to be approved twice through the web ui" do
      proposal = create(:proposal, :with_approver)
      login_as(proposal.approvers.first)

      post :approve, id: proposal.id

      expect(proposal.reload.approved?).to be true
      expect(flash[:success]).not_to be_nil
      expect(flash[:alert]).to be_nil

      flash.clear
      post :approve, id: proposal.id

      expect(response.status).to eq(403)
    end

    it "won't allow different delegates to approve" do
      proposal = create(:proposal, :with_approver)
      delegate1, delegate2 = create(:user), create(:user)
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

      expect(response.status).to eq(403)
    end

    it "allows a delegate to approve via the web UI" do
      proposal = create(:proposal, :with_two_approvers)
      mailbox = proposal.approvers.second
      delegate = create(:user)
      mailbox.add_delegate(delegate)
      proposal.individual_steps.first.approve!
      login_as(delegate)

      post :approve, id: proposal.id

      expect(flash[:success]).not_to be_nil
      expect(flash[:alert]).to be_nil
      expect(proposal.reload.approved?).to be true
    end
  end
end
