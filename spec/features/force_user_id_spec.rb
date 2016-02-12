feature "Acts as a different User in request" do
  include EnvVarSpecHelper

  scenario "respects session for current_user" do
    wo = create(:ncr_work_order, :with_approvers)
    login_as(wo.proposal.requester)

    visit profile_path

    expect(page.find("h2")).to have_content(wo.proposal.requester.email_address)
  end

  scenario "respects FORCE_USER_ID to override current_user" do
    with_env_var("FORCE_USER_ID", user.id.to_s) do
      user = create(:user, client_slug: "gsa18f")
      wo = create(:ncr_work_order, :with_approvers)
      login_as(wo.proposal.requester)

      visit profile_path

      expect(page.find("h2")).to have_content(user.email_address)
    end
  end
end
