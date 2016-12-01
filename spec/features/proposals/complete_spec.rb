describe "Completing a proposal" do
  it "distinguishes user with multiple actionable steps" do
    proposal = create(:proposal, :with_serial_approvers)
    first_approver = proposal.approvers.first
    second_approver = proposal.approvers.last
    second_approver.add_delegate(first_approver)

    login_as(first_approver)
    visit proposal_path(proposal)
    click_on("Approve")

    expect(current_path).to eq(proposal_path(proposal))
    expect(page).to have_content("You have approved #{proposal.public_id}")

    login_as(second_approver)
    visit proposal_path(proposal)
    click_on("Approve")

    expect(current_path).to eq(proposal_path(proposal))
    expect(page).to have_content("You have approved #{proposal.public_id}")
  end

  it "responds with error message when step cannot be acted on", :js do
    proposal = create(:ncr_work_order, :with_approvers).proposal
    first_step = proposal.individual_steps.first
    first_approver = proposal.approvers.first
    first_step.update_attributes!(status: "foobar")
    login_as(first_approver)
    visit proposal_path(proposal)
    page.save_screenshot('../screen.png', full: true)
    click_on("Approve")
    

    expect(current_path).to eq(proposal_path(proposal))
    expect(page).to have_content(I18n.t("errors.policies.proposal.step_complete"))
  end

  it "sends email to observers and requester when proposal is complete", :email do
    proposal = create(:proposal, :with_approver)
    proposal.add_observer(create(:user))

    login_as(proposal.approvers.first)
    visit proposal_path(proposal)
    click_on("Approve")

    visit proposal_path(proposal)
    expect(proposal.observers.length).to eq(1)
    expect(deliveries.length).to eq(2)
  end
end
