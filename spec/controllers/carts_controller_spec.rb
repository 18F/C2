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
  end

  describe('index') do
    it 'should find the open cart' do
      get :index, id: user2.id
      expect(assigns(:open_carts).first).to eq(@cart1)
    end

    it 'should find nothing' do
      get :index, id: user4.id
      expect(assigns(:open_carts).first).to be_nil
    end

    it 'should find the approved cart' do
      @cart1.update_attributes(status: 'approved')
      get :index, id: user2.id
      expect(assigns(:closed_carts).first).to eq(@cart1)
    end

    it 'should find the rejected cart' do
      @cart1.update_attributes(status: 'rejected')
      get :index, id: user2.id
      expect(assigns(:closed_carts).first).to eq(@cart1)
    end
  end
end