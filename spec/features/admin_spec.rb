describe "admin" do
  it "does not allow Delete of Users" do
    user = create(:user)
    user.add_role("admin")
    login_as(user)

    visit admin_users_path

    expect(page).to_not have_content("Delete")
  end

  it "does not allow editing of approval delegates" do
    user = create(:user)
    user.add_role("admin")
    other_user = create(:user)
    approval_delegate = create(:approval_delegate, assigner: user, assignee: other_user)

    login_as(user)
    visit edit_admin_user_path(user)
    visit admin_approval_delegate_path(approval_delegate)

    expect(page).not_to have_content("Edit Approval Delegate")
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
end
