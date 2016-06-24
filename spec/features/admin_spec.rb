describe "admin" do
  it "does not allow Delete of Users" do
    login_as_admin_user

    visit admin_users_path

    expect(page).to_not have_content("Delete")
  end

  it "does not allow editing of user delegates" do
    user = login_as_admin_user
    other_user = create(:user)
    user_delegate = create(:user_delegate, assigner: user, assignee: other_user)

    visit edit_admin_user_path(user)
    visit admin_user_delegate_path(user_delegate)

    expect(page).not_to have_content("Edit User Delegate")
  end

  it "does not allow delete of proposals" do
    login_as_admin_user
    _proposal = create(:proposal)

    visit admin_proposals_path

    expect(page).to_not have_content("Delete")
  end

  it "does not allow edit of proposals" do
    login_as_admin_user
    _proposal = create(:proposal)

    visit admin_proposals_path

    expect(page).not_to have_content("Edit")
  end

  it "shows user.display_name when viewing User records" do
    user = login_as_admin_user
    create(:proposal, requester: user)

    visit admin_proposals_path

    expect(page).to have_content(user.display_name)
  end

  it "contains reindex button link" do
    login_as_admin_user

    visit admin_dashboard_path

    expect(page).to have_content("Re-index Proposals")
  end

  it "creates new User" do
    login_as_admin_user

    visit new_admin_user_path

    fill_in "user[first_name]", with: "test"
    fill_in "user[last_name]", with: "user"
    fill_in "user[email_address]", with: "testuser@example.com"
    select "test", from: "user[client_slug]"
    select "observer", from: "user[role_ids][]"
    click_button "Create User"

    expect(page).to have_content("test user <testuser@example.com>")
  end

  it "uses compatible timezone strings for User profile editing" do
    user = login_as_admin_user

    visit admin_user_path(user)

    expect(page).to_not have_content("(GMT-05:00) Eastern Time (US & Canada)")
  end

  it "triggers actions on Complete button click", :email do
    login_as_admin_user
    proposal = create(:proposal, :with_serial_approvers)

    deliveries.clear
    visit admin_proposal_path(proposal)
    click_link "Complete"

    expect(deliveries.count).to eq(3)
    proposal.reload
    expect(proposal).to be_completed
  end

  it "does not trigger actions on Complete Without Notifications button click" do
    login_as_admin_user
    proposal = create(:proposal, :with_serial_approvers)

    deliveries.clear
    visit admin_proposal_path(proposal)
    click_link "Complete without notifications"

    expect(deliveries.count).to eq(0)
    proposal.reload
    expect(proposal).to be_completed
  end

  it "triggers actions, no email notifications, on Step edit" do
    user = login_as_admin_user
    proposal = create(:proposal, :with_serial_approvers)
    first_step = proposal.individual_steps.first

    deliveries.clear
    visit edit_admin_step_path(first_step)
    expect(page).to have_content("actionable")

    select "completed", from: "step[status]"
    click_button "Update Approval"

    expect(page).to have_content("Approval was successfully updated")
    expect(deliveries.count).to eq(0)
    first_step.reload
    expect(first_step.completed_at).to_not be_nil
    expect(first_step.completer).to eq(user)
  end

  def login_as_admin_user
    user = create(:user, :admin)
    login_as(user)
    user
  end
end
