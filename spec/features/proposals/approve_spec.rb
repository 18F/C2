describe "Approving a proposal" do
  it "can be done by an approver" do
    Timecop.freeze do
      proposal = create(:proposal, :with_approver)
      login_as(proposal.approvers.first)
      visit "/proposals/#{proposal.id}"
      click_on("Approve")

      expect(current_path).to eq("/proposals/#{proposal.id}")
      expect(page).to have_content("You have approved #{proposal.public_id}")

      approval = Proposal.last.individual_steps.first
      expect(approval.status).to eq("approved")
      expect(approval.approved_at.utc.to_s).to eq(Time.now.utc.to_s)
    end
  end

  it "doesn't send multiple emails to approvers who are also observers" do
    proposal = create(:proposal, :with_approver)
    proposal.add_observer(proposal.approvers.first.email_address)

    login_as(proposal.approvers.first)
    visit "/proposals/#{proposal.id}"
    click_on("Approve")

    expect(proposal.observers.length).to eq(1)
    expect(deliveries.length).to eq(1)
  end
end
