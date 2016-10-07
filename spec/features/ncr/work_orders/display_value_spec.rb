describe "the values displayed on work_order" do
  let(:work_order)   { create(:ncr_work_order) }
  let(:ncr_proposal) { work_order.proposal }

  before do
    work_order.setup_approvals_and_observers
    login_as(work_order.requester)
  end

end
