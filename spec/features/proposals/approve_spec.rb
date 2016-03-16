describe "Approving a proposal" do
  include EnvVarSpecHelper

  it "can be done by an approver" do
    Timecop.freeze do
      proposal = create(:proposal, :with_approver)
      login_as(proposal.approvers.first)
      visit "/proposals/#{proposal.id}"
      click_on("Approve")

      expect(current_path).to eq("/proposals/#{proposal.id}")
      expect(page).to have_content("You have approved #{proposal.public_id}")

      approval = Proposal.last.individual_steps.first
      expect(approval.status).to eq("completed")
      expect(approval.completed_at.utc.to_s).to eq(Time.now.utc.to_s)
    end
  end

  it "distinguishes user with multiple actionable steps" do
    proposal = create(:proposal, :with_serial_approvers)
    first_approver = proposal.approvers.first
    second_approver = proposal.approvers.last
    second_approver.add_delegate(first_approver)

    login_as(first_approver)
    visit proposal_path(proposal)
    click_on("Approve")

    expect(current_path).to eq("/proposals/#{proposal.id}")
    expect(page).to have_content("You have approved #{proposal.public_id}")

    login_as(second_approver)
    visit proposal_path(proposal)
    click_on("Approve")

    expect(current_path).to eq("/proposals/#{proposal.id}")
    expect(page).to have_content("You have approved #{proposal.public_id}")
  end

  it "doesn't send multiple emails to approvers who are also observers" do
    with_env_var("NO_WELCOME_EMAIL", "true") do
      proposal = create(:proposal, :with_approver)
      proposal.add_observer(proposal.approvers.first)

      login_as(proposal.approvers.first)
      visit "/proposals/#{proposal.id}"
      click_on("Approve")

      expect(proposal.observers.length).to eq(1)
      expect(deliveries.length).to eq(1)
    end
  end
end
