describe Ncr::WorkOrderPolicy do
  subject { described_class }

  permissions :can_edit? do
    let(:work_order) { FactoryGirl.create(:ncr_work_order, :with_approvers) }

    it "allows the requester to edit it" do
      expect(subject).to permit(work_order.requester, work_order)
    end

    it "doesn't allow an approver to edit it" do
      expect(subject).not_to permit(work_order.approvers[0], work_order)
      expect(subject).not_to permit(work_order.approvers[1], work_order)
    end

    it "doesn't allow an observer to edit it"

    it "does not allow anyone else to edit it" do
      expect(subject).not_to permit(FactoryGirl.create(:user), work_order)
    end
  end
end
