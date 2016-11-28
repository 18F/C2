describe "User Delegates" do
  it "allows delegate to approve a proposal", :js do
    proposal = create(:ncr_work_order, :with_approvers).proposal
    delegate = create(:user, client_slug: "ncr")
    approver = proposal.approvers.first
    approver.add_delegate(delegate)
    approver.save!

    login_as(delegate)
    visit proposal_path(proposal)
    click_on("Approve")

    expect(current_path).to eq(proposal_path(proposal))
    expect(page).to have_content("You have approved #{proposal.public_id}")
    expect(page).to have_content(delegate.full_name)
  end

  it "delegates can view work order after approval by different delegate", :js do
    proposal = create(:ncr_work_order, :with_approvers).proposal
    delegate = create(:user, client_slug: "ncr")
    delegate_two = create(:user, client_slug: "ncr")
    approver = proposal.approvers.first
    approver.add_delegate(delegate)
    approver.add_delegate(delegate_two)
    approver.save!

    login_as(delegate)
    visit proposal_path(proposal)
    click_on("Approve")

    expect(page).to have_content("You have approved #{proposal.public_id}")

    login_as(delegate_two)
    visit proposal_path(proposal)
    expect(page.status_code).to eq(200)
    expect(page).to have_content(delegate.full_name)
  end
end
