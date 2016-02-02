describe "admin" do
  it "does not allow Delete of Users" do
    user = create(:user)
    user.add_role("admin")
    login_as(user)

    visit admin_users_path

    expect(page).to_not have_content("Delete")
  end

  it "does not allow editing of user delegates" do
    user = create(:user)
    user.add_role("admin")
    other_user = create(:user)
    user_delegate = create(:user_delegate, assigner: user, assignee: other_user)

    login_as(user)
    visit edit_admin_user_path(user)
    visit admin_user_delegate_path(user_delegate)

    expect(page).not_to have_content("Edit User Delegate")
  end

  it "does not allow delete of proposals" do
    user = create(:user)
    user.add_role("admin")
    _proposal = create(:proposal)
    login_as(user)

    visit admin_proposals_path

    expect(page).to_not have_content("Delete")
  end

  it "does not allow edit of proposals" do
    user = create(:user)
    user.add_role("admin")
    _proposal = create(:proposal)
    login_as(user)

    visit admin_proposals_path

    expect(page).not_to have_content("Edit")
  end

  it "shows user.display_name when viewing User records" do
    user = create(:user)
    user.add_role("admin")
    proposal = create(:proposal, requester: user)
    login_as(user)

    visit admin_proposals_path

    expect(page).to have_content(user.display_name)
  end

  it "contains reindex button link" do
    user = create(:user, :admin)
    login_as(user)

    visit admin_dashboard_path

    expect(page).to have_content("Re-index Proposals")
  end
end
