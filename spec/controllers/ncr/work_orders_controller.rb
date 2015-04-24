describe Ncr::WorkOrdersController do
  describe 'editing' do
    let (:work_order) { FactoryGirl.create(:ncr_work_order, :with_proposal,
                                           :with_requester) }

    it 'does not modify the work order when there is a blank approver' do
      login_as(work_order.proposal.requester)
      post :update, {id: work_order.proposal.id, approver_email: '',
                     ncr_work_order: {expense_type: 'BA61', name: 'new name'}}
      expect(flash[:success]).not_to be_present
      expect(flash[:error]).to be_present
      work_order.reload
      expect(work_order.name).not_to eq('new name')
    end

    it 'does not modify the work order when there is a bad edit' do
      login_as(work_order.proposal.requester)
      post :update, {id: work_order.proposal.id, approver_email: 'a@b.com',
                     ncr_work_order: {expense_type: 'BA61', amount: 999999}}
      expect(flash[:success]).not_to be_present
      expect(flash[:error]).to be_present
      work_order.reload
      expect(work_order.amount).not_to eq(999999)
    end
  end
end
