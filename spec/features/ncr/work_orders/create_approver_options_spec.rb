feature "Approver options during create", :js do
  scenario "inactive users do not appear as potential approvers" do
    approver = create(:user, client_slug: "ncr")
    inactive_user = create(:user, client_slug: "ncr", active: false)

    login_as(requester)
    visit new_ncr_work_order_path

    within(".ncr_work_order_approving_official_email") do
      find(".selectize-control").click
      expect(page).not_to have_content(inactive_user.email_address)
      expect(page).to have_content(approver.email_address)
    end
  end

  scenario "does not show system approver emails as approver options" do
    _approving_official = create(:user, client_slug: "ncr")

    login_as(requester)
    visit new_ncr_work_order_path

    expect_page_not_to_have_selectized_options(
      "ncr_work_order_approving_official_email",
      Ncr::Mailboxes.ba61_tier1_budget,
      Ncr::Mailboxes.ba61_tier2_budget,
      Ncr::Mailboxes.ba80_budget,
      Ncr::Mailboxes.ool_ba80_budget
    )
  end

  scenario "does not show requester as approver option" do
    login_as(requester)
    visit new_ncr_work_order_path

    expect_page_not_to_have_selectized_options(
      "ncr_work_order_approving_official_email",
      requester.email_address
    )
  end

  scenario "defaults to no approver if there was no previous request" do
    _approver = create(:user, client_slug: "ncr")
    login_as(requester)

    visit new_ncr_work_order_path

    expect_page_not_to_have_selected_selectize_option(
      "ncr_work_order_approving_official_email",
      /@example.com/
    )
  end

  scenario "defaults to the approver from the last request" do
    login_as(requester)
    proposal = create(:proposal, :with_approver, requester: requester, client_slug: "ncr")

    visit new_ncr_work_order_path

    expect_page_to_have_selected_selectize_option(
      "ncr_work_order_approving_official_email",
       proposal.approvers.first.email_address
    )
  end

  def requester
    @_requester ||= create(:user, client_slug: "ncr")
  end
end
