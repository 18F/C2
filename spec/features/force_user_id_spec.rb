describe "Acts as a different User in request" do
  let(:user) { FactoryGirl.create(:user, client_slug: 'gsa18f') }

  it "respects session for current_user" do
    wo = FactoryGirl.create(:ncr_work_order, :with_approvers)
    login_as(wo.proposal.requester)
    visit '/me'
    expect(page.find('h2')).to have_content(wo.proposal.requester.email_address)
  end

  it "respects FORCE_USER_ID to override current_user" do
    with_env_var('FORCE_USER_ID', user.id.to_s) do
      wo = FactoryGirl.create(:ncr_work_order, :with_approvers)
      login_as(wo.proposal.requester)
      visit '/me'
      expect(page.find('h2')).to have_content(user.email_address)
    end
  end

end
