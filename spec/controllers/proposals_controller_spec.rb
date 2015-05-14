describe ProposalsController do
  let(:user) { FactoryGirl.create(:user) }

  describe '#index' do
    before do
      login_as(user)
    end

    it 'sets @proposals' do
      proposal1 = FactoryGirl.create(:proposal, requester: user)
      proposal2 = FactoryGirl.create(:proposal)
      proposal2.approvals.create!(user: user)

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

    it "supports text searching by NCR project_title" do
      work_order = FactoryGirl.create(:ncr_work_order, :with_proposal)
      proposal2 = work_order.proposal
      proposal2.update_attributes!(requester: user)

      get :query, text: work_order.project_title
      expect(assigns(:proposals)).to eq([proposal2])
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
      proposal = FactoryGirl.create(:proposal, :with_approver, :with_cart)
      approval = proposal.approvals.first
      token = approval.create_api_token!

      post :approve, id: proposal.id, cch: token.access_token

      expect(controller.send(:current_user)).to eq(approval.user)
    end
  end
end
