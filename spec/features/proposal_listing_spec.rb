describe "Listing Page" do
  let!(:user){ FactoryGirl.create(:user) }
  let!(:default){ FactoryGirl.create(:proposal, requester: user) }
  let!(:ncr){
    ncr = FactoryGirl.create(:ncr_work_order, :with_proposal)
    ncr.proposal.update_attribute(:requester, user)
    ncr
  }
  let!(:gsa18f){
    gsa18f = FactoryGirl.create(:gsa18f_procurement, :with_proposal)
    gsa18f.proposal.update_attribute(:requester, user)
    gsa18f
  }
  before do
    login_as(user)
  end

  it "should not explode if client is not set" do
    visit '/proposals'
    expect(page).to have_content(default.public_identifier)
    expect(page).to have_content(ncr.public_identifier)
    expect(page).to have_content(gsa18f.public_identifier)
  end

  it "should not explode if client is ncr" do
    user.update_attribute(:client_slug, 'ncr')
    visit '/proposals'
    expect(page).to have_content(default.public_identifier)
    expect(page).to have_content(ncr.public_identifier)
    expect(page).to have_content(gsa18f.public_identifier)
  end

  it "should not explode if client is gsa18f" do
    user.update_attribute(:client_slug, 'gsa18f')
    visit '/proposals'
    expect(page).to have_content(default.public_identifier)
    expect(page).to have_content(ncr.public_identifier)
    expect(page).to have_content(gsa18f.public_identifier)
  end
end
