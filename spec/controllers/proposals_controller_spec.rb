describe ProposalsController do
  include ReturnToHelper
  let(:user) { FactoryGirl.create(:user) }

  describe '#index' do
    before do
      login_as(user)
    end

    it 'sets @proposals' do
      proposal1 = FactoryGirl.create(:proposal, requester: user)
      proposal2 = FactoryGirl.create(:proposal)
      proposal2.approvals.create!(user: user, status: 'actionable')

      get :index
      expect(assigns(:proposals).sort).to eq [proposal1, proposal2]
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

      expect(assigns(:proposals).size).to eq(2)
    end
  end

  describe '#show' do
    before do
      login_as(user)
    end

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

  describe '#query' do
    let!(:proposal) { FactoryGirl.create(:proposal, requester: user) }
    before do
      login_as(user)
    end

    it 'should only include proposals user is a part of' do
      get :query
      expect(assigns(:proposals)).to eq([proposal])
    end

    it 'should filter results by date range' do
      past_proposal = FactoryGirl.create(
        :proposal, created_at: Date.new(2012, 5, 6), requester: user)
      get :query
      expect(assigns(:proposals)).to eq([proposal, past_proposal])

      get :query, start_date: '2012-05-04', end_date: '2012-05-07'
      expect(assigns(:proposals)).to eq([past_proposal])

      get :query, start_date: '2012-05-04', end_date: '2012-05-06'
      expect(assigns(:proposals)).to eq([])
    end

    it 'ignores bad input' do
      get :query, start_date: 'dasdas'
      expect(assigns(:proposals)).to eq([proposal])
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
  end
end
