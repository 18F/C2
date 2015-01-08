describe CartsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:approval_group1) { FactoryGirl.create(:approval_group, name: 'test-approval-group1') }

  before do
    UserRole.create!(user_id: user.id, approval_group_id: approval_group1.id, role: 'requester')
    p = {'approvalGroup' => 'test-approval-group1', 'cartName' => 'cart1' }
    @cart1 = Commands::Approval::InitiateCartApproval.new.perform(p)
    session[:user] = {}
  end

  describe '#archive' do
    it 'should show all the closed carts' do
      session[:user]['email'] = user.email_address
      carts = Array.new
      (1..4).each do |i|
        p = {}
        p['approvalGroup'] =  'test-approval-group1'
        p['cartName'] = "cart#{i}"
        temp_cart = Commands::Approval::InitiateCartApproval.new.perform(p)
        temp_cart.update_attributes(status: 'approved') unless i==3
        carts.push(temp_cart)
      end
      get :archive
      expect(assigns(:closed_cart_full_list).size).to eq(3)
    end
  end
end