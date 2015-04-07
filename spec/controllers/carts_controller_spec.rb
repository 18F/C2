describe CartsController do
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
      proposal3 = FactoryGirl.create(:proposal, requester: user)

      get :index
      expect(assigns(:proposals).sort).to eq [
        @cart1.proposal, proposal2, proposal3]
    end
  end

  describe '#archive' do
    it 'should show all the closed carts' do
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
      expect(assigns(:closed_proposals_full_list).size).to eq(3)
    end
  end

  describe '#show' do
    it 'should allow the requester to see it' do
      proposal = FactoryGirl.create(:proposal, :with_cart, requester: user)
      get :show, id: proposal.cart.id
      expect(response).not_to redirect_to("/carts/")
      expect(flash[:alert]).not_to be_present
    end

    it 'should redirect random users' do
      proposal = FactoryGirl.create(:proposal, :with_cart,
                                    requester: FactoryGirl.create(:user))
      get :show, id: proposal.cart.id
      expect(response).to redirect_to(carts_path)
      expect(flash[:alert]).to be_present
    end
  end
end
