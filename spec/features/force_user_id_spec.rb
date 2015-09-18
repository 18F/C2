describe "Acts as a different User in request" do
  let(:user) { FactoryGirl.create(:user, client_slug: 'gsa18f') }

  it "respects session for current_user" do
    wo = FactoryGirl.create(:ncr_work_order, :with_approvers)
    login_as(wo.proposal.requester)
    visit '/me'
    expect(page.find('h2')).to have_content(wo.proposal.requester.email_address)
  end

  # can't use with_env here because we need to use factory object as env var value
  it "respects FORCE_USER_ID to override current_user" do
    ENV['FORCE_USER_ID'] = user.id.to_s
    wo = FactoryGirl.create(:ncr_work_order, :with_approvers)
    login_as(wo.proposal.requester)
    visit '/me'
    expect(page.find('h2')).to have_content(user.email_address)
  end

end
