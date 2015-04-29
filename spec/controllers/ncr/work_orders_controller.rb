describe Ncr::WorkOrdersController do
  describe 'editing' do
    let (:work_order) { FactoryGirl.create(:ncr_work_order, :with_proposal,
                                           :with_requester) }
    before do
      login_as(work_order.proposal.requester)
    end

    it 'does not modify the work order when there is a blank approver' do
      post :update, {id: work_order.proposal.id, approver_email: '',
                     ncr_work_order: {expense_type: 'BA61', name: 'new name'}}
      expect(flash[:success]).not_to be_present
      expect(flash[:error]).to be_present
      work_order.reload
      expect(work_order.name).not_to eq('new name')
    end

    it 'does not modify the work order when there is a bad edit' do
      post :update, {id: work_order.proposal.id, approver_email: 'a@b.com',
                     ncr_work_order: {expense_type: 'BA61', amount: 999999}}
      expect(flash[:success]).not_to be_present
      expect(flash[:error]).to be_present
      work_order.reload
      expect(work_order.amount).not_to eq(999999)
    end

    it 'allows the approver to be edited' do
      post :update, {id: work_order.proposal.id, approver_email: 'a@b.com',
                     ncr_work_order: {expense_type: 'BA61'}}
      work_order.reload
      expect(work_order.approvers.first.user_email_address).to eq('a@b.com')
    end

    it 'does not modify the approver if already approved' do
      work_order.proposal.approvals.first.approve!
      post :update, {id: work_order.proposal.id, approver_email: 'a@b.com',
                     ncr_work_order: {expense_type: 'BA61'}}
      work_order.reload
      expect(work_order.approvers.map(&:user_email_address)).not_to contain(
        'a@b.com')
    end
  end
end
