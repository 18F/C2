describe ApprovalGroupsController do
  let(:user1) { FactoryGirl.create(:user, email_address: 'user1@some-dot-gov.gov') }
  let(:user2) { FactoryGirl.create(:user, email_address: 'user2@some-dot-gov.gov') }
  let(:user3) { FactoryGirl.create(:user, email_address: 'user3@some-dot-gov.gov') }
  let(:approval_group1) { FactoryGirl.create(:approval_group, name: 'test-approval-group') }
  let(:approval_group2) { FactoryGirl.create(:approval_group, name: 'test-approval-group2') }


  context 'search' do
    it 'can find a group with email' do
      UserRole.create!(user_id: user1.id, approval_group_id: approval_group1.id, role: 'approver')
      UserRole.create!(user_id: user2.id, approval_group_id: approval_group1.id, role: 'requester')
      get :search,  email: user2.email_address
      expect(assigns(:groups).first).to eq(approval_group1)
      # expect(response).to render_template(:index)
    end

    it 'finds nothing when no group available' do
      UserRole.create!(user_id: user1.id, approval_group_id: approval_group1.id, role: 'approver')
      UserRole.create!(user_id: user2.id, approval_group_id: approval_group1.id, role: 'requester')
      get :search,  email: 'user222@some-dot-gov.gov'
      expect(assigns(:groups)).to be_empty
    end
  end
end
