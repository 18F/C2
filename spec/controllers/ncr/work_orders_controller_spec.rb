describe Ncr::WorkOrdersController do
  describe 'creating' do
    before do
      login_as(FactoryGirl.create(:user))
    end
    let (:params) {{
      ncr_work_order: {
        amount: '111.22', expense_type: 'BA80', vendor: 'Vendor',
        not_to_exceed: '0', building_number: Ncr::BUILDING_NUMBERS[0],
        emergency: '0', rwa_number: 'A1234567', org_code: Ncr::Organization.all[0],
        code: 'Work Order', project_title: 'Title', description: 'Desc'},
      approver_email: 'bob@example.gov'
    }}

    it 'sends an email to the first approver' do
      post :create, params
      ncr = Ncr::WorkOrder.order(:id).last
      expect(ncr.code).to eq 'Work Order'
      expect(ncr.approvers.first.email_address).to eq 'bob@example.gov'
      expect(email_recipients).to eq(['bob@example.gov', ncr.requester.email_address].sort)
    end

    it 'does not error on missing attachments' do
      params[:ncr_work_order][:amount] = '111.33'
      params[:attachments] = []
      post :create, params
      ncr = Ncr::WorkOrder.order(:id).last
      expect(ncr.amount).to eq 111.33
      expect(ncr.proposal.attachments.count).to eq 0
    end

    it 'does not error on malformed attachments' do
      params[:ncr_work_order][:amount] = '111.34'
      params[:attachments] = 'abcd'
      post :create, params
      ncr = Ncr::WorkOrder.order(:id).last
      expect(ncr.amount).to eq 111.34
      expect(ncr.proposal.attachments.count).to eq 0
    end

    it 'adds attachments if present' do
      params[:ncr_work_order][:amount] = '111.35'
      params[:attachments] = [
        fixture_file_upload('icon-user.png', 'image/png'),
        fixture_file_upload('icon-user.png', 'image/png'),
      ]
      post :create, params
      ncr = Ncr::WorkOrder.order(:id).last
      expect(ncr.amount).to eq 111.35
      expect(ncr.proposal.attachments.count).to eq 2
    end
  end

  describe '#edit' do
    let (:work_order) { FactoryGirl.create(:ncr_work_order, :with_approvers) }
    let (:requester) { work_order.proposal.requester }
    before do
      login_as(requester)
    end

    it 'does not display a message when the proposal is not fully approved' do
      get :edit, {id: work_order.id}
      expect(flash[:warning]).not_to be_present
    end

    it 'displays a warning message when editing a fully-approved proposal' do
      work_order.approve!
      get :edit, {id: work_order.id}
      expect(flash[:warning]).to be_present
    end

    it 'does not explode if editing an emergency' do
      work_order = FactoryGirl.create(:ncr_work_order, :is_emergency,
                                      requester: requester)
      get :edit, {id: work_order.id}
    end
  end

  describe '#update' do
    let (:work_order) { FactoryGirl.create(:ncr_work_order, :with_approvers) }
    let (:requester) { work_order.proposal.requester }
    before do
      login_as(requester)
    end

    it 'does not modify the work order when there is a blank approver' do
      post :update, {id: work_order.id, approver_email: '',
                     ncr_work_order: {expense_type: 'BA61', name: 'new name'}}
      expect(flash[:success]).not_to be_present
      expect(flash[:error]).to be_present
      work_order.reload
      expect(work_order.name).not_to eq('new name')
    end

    it 'does not modify the work order when there is a bad edit' do
      post :update, {id: work_order.id, approver_email: 'a@b.com',
                     ncr_work_order: {expense_type: 'BA61', amount: 999999}}
      expect(flash[:success]).not_to be_present
      expect(flash[:error]).to be_present
      work_order.reload
      expect(work_order.amount).not_to eq(999999)
    end

    it 'allows the approver to be edited' do
      post :update, {id: work_order.id, approver_email: 'a@b.com',
                     ncr_work_order: {expense_type: 'BA61'}}
      work_order.reload
      expect(work_order.approvers.first.email_address).to eq('a@b.com')
    end

    it 'does not modify the approver if already approved' do
      work_order.user_approvals.first.approve!
      post :update, {id: work_order.id, approver_email: 'a@b.com',
                     ncr_work_order: {expense_type: 'BA61'}}
      work_order.reload
      expect(work_order.approvers.map(&:email_address)).not_to include('a@b.com')
    end

    it 'will not modify emergency status on non-emergencies' do
      expect(work_order.approvals.empty?).to be false
      expect(work_order.observers.empty?).to be true
      post :update, {id: work_order.id, approver_email: work_order.approvers.first.email_address,
                     ncr_work_order: {expense_type: 'BA61', emergency: '1'}}
      work_order.reload
      expect(work_order.emergency).to be false
      expect(work_order.approvals.empty?).to be false
      expect(work_order.observers.empty?).to be true
    end

    it 'will not modify emergency status on emergencies' do
      work_order = FactoryGirl.create(:ncr_work_order, :is_emergency, requester: requester)
      expect(work_order.approvals.empty?).to be true
      expect(work_order.observers.empty?).to be false
      post :update, {id: work_order.id, approver_email: work_order.observers.first.email_address,
                     ncr_work_order: {expense_type: 'BA61', building_number: 'BillDing', emergency: '0'}}
      work_order.reload
      expect(work_order.emergency).to be true
      expect(work_order.building_number).to eq "BillDing"
      expect(work_order.approvals.empty?).to be true
      expect(work_order.observers.empty?).to be false
    end
  end
end
