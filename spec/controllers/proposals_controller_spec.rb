describe ProposalsController do
  # TODO clean up this setup
  let(:user) { FactoryGirl.create(:user) }
  let(:approval_group1) { FactoryGirl.create(:approval_group, name: 'test-approval-group1') }

  before do
    UserRole.create!(user_id: user.id, approval_group_id: approval_group1.id, role: 'requester')
    params = {'approvalGroup' => 'test-approval-group1', 'cartName' => 'cart1' }
    @cart1 = Commands::Approval::InitiateCartApproval.new.perform(params)
  end

  describe '#index' do
    before do
      login_as(user)
    end

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
    before do
      login_as(user)
    end

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
    before do
      login_as(user)
    end

    it 'should allow the requester to see it' do
      proposal = FactoryGirl.create(:proposal, :with_cart, requester: user)
      get :show, id: proposal.id
      expect(response).not_to redirect_to("/proposals/")
      expect(flash[:alert]).not_to be_present
    end

    it 'should redirect random users' do
      proposal = FactoryGirl.create(:proposal, :with_cart,
                                    requester: FactoryGirl.create(:user))
      get :show, id: proposal.id
      expect(response).to redirect_to(proposals_path)
      expect(flash[:alert]).to be_present
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
