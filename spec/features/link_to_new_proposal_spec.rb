describe "Link to New Proposal" do
  it "is not visible if the user has no client" do
    login_as(FactoryGirl.create(:user))
    visit '/'
    expect(page).not_to have_content('New NCR Request')
  end

  it "is not visible if the user has a random client" do
    login_as(FactoryGirl.create(:user, client_slug: "something else"))
    visit '/'
    expect(page).not_to have_content('New NCR Request')
  end

  it "is visible if the user is NCR" do
    login_as(FactoryGirl.create(:user, client_slug: "ncr"))
    visit '/'
    expect(page).to have_content('New NCR Request')
    click_on 'New NCR Request'
    expect(current_path).to eq('/ncr/work_orders/new')
  end
end
