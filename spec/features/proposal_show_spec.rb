describe 'GET /proposals/:id' do
  let(:user) { FactoryGirl.create(:user) }
  let(:proposal) { FactoryGirl.create(:proposal, requester: user) }

  it "shows the link to the history for admins" do
    user.add_role('admin')
    login_as(user)

    visit "/proposals/#{proposal.id}"

    expect(page).to have_link("View history")
  end

  it "doesn't show the link to the history for normal users" do
    login_as(user)
    visit "/proposals/#{proposal.id}"
    expect(page).to_not have_link("View history")
  end
end
