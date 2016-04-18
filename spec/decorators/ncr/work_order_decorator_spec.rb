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

    it "returns final approver when status is completed" do
      wo = create(:ncr_work_order, :with_approvers).decorate
      wo.proposal.complete!
      expect(wo).to be_completed
      expect(wo.current_approver_email_address).to eq(wo.approvers.last.email_address)
    end
  end

  describe "#translated_key" do
    it "fetches the correct translation" do
      wo = build_stubbed(:ncr_work_order).decorate
      expect(wo.translated_key("soc_code")).to eq I18n.t("decorators.ncr/work_order.soc_code")
    end
  end
end
