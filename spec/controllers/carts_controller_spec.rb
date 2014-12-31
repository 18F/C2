describe CartsController do
  let(:user1) { FactoryGirl.create(:user, email_address: 'user1@some-dot-gov.gov') }
  let(:user2) { FactoryGirl.create(:user, email_address: 'user2@some-dot-gov.gov') }
  let(:user3) { FactoryGirl.create(:user, email_address: 'user3@some-dot-gov.gov') }
  let(:user4) { FactoryGirl.create(:user, email_address: 'user4@some-dot-gov.gov') }
  let(:approval_group1) { FactoryGirl.create(:approval_group, name: 'test-approval-group1') }
  let(:approval_group2) { FactoryGirl.create(:approval_group, name: 'test-approval-group2') }
  @cart1


  before do
    UserRole.create!(user_id: user1.id, approval_group_id: approval_group1.id, role: 'approver')
    UserRole.create!(user_id: user2.id, approval_group_id: approval_group1.id, role: 'requester')
    UserRole.create!(user_id: user3.id, approval_group_id: approval_group1.id, role: 'approver')
    #why do I have to do it this way? I dunno, but I do. :/
    p = {}
    p['approvalGroup'] =  'test-approval-group1'
    p['cartName'] = 'cart1'
    @cart1 = Commands::Approval::InitiateCartApproval.new.perform(p)
    session[:user] = {}
  end

  describe('index') do

    it 'should find the open cart' do
      session[:user]['email'] = user2.email_address
      get :index
      expect(assigns(:open_carts).first).to eq(@cart1)
    end

    it 'should find nothing' do
      session[:user]['email'] = user4.email_address
      get :index
      expect(assigns(:open_carts).first).to be_nil
    end

    it 'should find the approved cart' do
      session[:user]['email'] = user2.email_address
      @cart1.update_attributes(status: 'approved')
      get :index
      expect(assigns(:closed_carts).first).to eq(@cart1)
    end

    it 'should find the rejected cart' do
      session[:user]['email'] = user2.email_address
      @cart1.update_attributes(status: 'rejected')
      get :index
      expect(assigns(:closed_carts).first).to eq(@cart1)
    end
  end

  describe('archive') do
    it 'should show all the closed carts' do
      session[:user]['email'] = user2.email_address
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