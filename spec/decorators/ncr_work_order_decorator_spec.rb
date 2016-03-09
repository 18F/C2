describe Ncr::WorkOrderDecorator do
  describe "#current_approver_email_address" do
    it "returns NOT FOUND string when WorkOrder has no approvers" do
      wo = create(:ncr_work_order).decorate
      expect(wo.current_approver_email_address).to eq(Ncr::WorkOrderDecorator::NO_APPROVER_FOUND)
    end

    it "returns EMERGENCY string when WorkOrder is emergency" do
      wo = create(:ncr_work_order, emergency: true).decorate
      expect(wo.current_approver_email_address).to eq(Ncr::WorkOrderDecorator::EMERGENCY_APPROVER_EMAIL)
    end

    it "returns pending (current) approver email address" do
      wo = create(:ncr_work_order, :with_approvers).decorate
      expect(wo.current_approver_email_address).to eq(wo.approvers.first.email_address)
    end

    it "returns current approver email address when status is pending" do
      wo = create(:ncr_work_order, :with_approvers).decorate
      expect(wo.current_approver_email_address).to eq(wo.current_approver_email_address)
    end

    it "returns final approver when status is approved" do
      wo = create(:ncr_work_order, :with_approvers).decorate
      wo.proposal.approve!
      expect(wo.approved?).to be_truthy
      expect(wo.current_approver_email_address).to eq(wo.approvers.last.email_address)
    end
  end
end
