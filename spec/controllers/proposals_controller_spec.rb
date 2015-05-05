describe ProposalsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:approval_group1) { FactoryGirl.create(:approval_group, name: 'test-approval-group1') }

  before do
    UserRole.create!(user_id: user.id, approval_group_id: approval_group1.id, role: 'requester')
    params = {'approvalGroup' => 'test-approval-group1', 'cartName' => 'cart1' }
    @cart1 = Commands::Approval::InitiateCartApproval.new.perform(params)
    login_as(user)
  end

  describe '#index' do
    it 'sets @proposals' do
      approval_group1

      proposal2 = FactoryGirl.create(:proposal, requester: user)
      proposal3 = FactoryGirl.create(:proposal)
      proposal3.approvals.create!(user: user)

      get :index
      expect(assigns(:proposals).sort).to eq [
        @cart1.proposal, proposal2, proposal3]
    end
  end

  describe '#archive' do
    it 'should show all the closed proposals' do
      carts = Array.new
      (1..4).each do |i|
        params = {}
        params['approvalGroup'] =  'test-approval-group1'
        params['cartName'] = "cart#{i}"
        temp_cart = Commands::Approval::InitiateCartApproval.new.perform(params)
        temp_cart.approve! unless i==3
        carts.push(temp_cart)
      end
      get :archive
      expect(assigns(:proposals).size).to eq(3)
    end
  end

  describe '#show' do
    it 'should allow the requester to see it' do
      proposal = FactoryGirl.create(:proposal, :with_cart, requester: user)
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
    it 'should only include proposals user is a part of' do
      FactoryGirl.create(:proposal)
      get :query
      expect(assigns(:proposals)).to eq([@cart1.proposal])
    end

    it 'should filter results by date range' do
      past_proposal = FactoryGirl.create(
        :proposal, created_at: Date.new(2012, 5, 6), requester: user)
      get :query
      expect(assigns(:proposals)).to eq([@cart1.proposal, past_proposal])

      get :query, start_date: '2012-05-04', end_date: '2012-05-07'
      expect(assigns(:proposals)).to eq([past_proposal])

      get :query, start_date: '2012-05-04', end_date: '2012-05-06'
      expect(assigns(:proposals)).to eq([])
    end

    it 'ignores bad input' do
      get :query, start_date: 'dasdas'
      expect(assigns(:proposals)).to eq([@cart1.proposal])
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
end
