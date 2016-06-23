feature "Approve a NCR work order" do
  context "when signed in as the approver" do
    context "last step is completed" do
      it "sends one email to the requester", :email do
        work_order = create(:ncr_work_order, :with_approvers)
        approver = work_order.individual_steps.last.user
        work_order.individual_steps.first.complete!
        deliveries.clear

        login_as(approver)
        visit proposal_path(work_order.proposal)
        click_on("Approve")

        expect(deliveries.length).to eq(1)
        expect(deliveries.first.to).to eq([work_order.proposal.requester.email_address])
      end
    end
  end
end
