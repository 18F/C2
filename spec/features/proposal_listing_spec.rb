describe "Listing Page" do
  around(:each) do |example|
    with_18f_procurement_env_variables(&example)
  end

  let!(:user){ FactoryGirl.create(:user) }
  let!(:default){ FactoryGirl.create(:proposal, requester: user) }
  let!(:ncr){
    ncr = FactoryGirl.create(:ncr_work_order)
    ncr.proposal.update_attribute(:requester, user)
    ncr
  }
  let!(:gsa18f){
    gsa18f = FactoryGirl.create(:gsa18f_procurement)
    gsa18f.proposal.update_attribute(:requester, user)
    gsa18f
  }
  before do
    login_as(user)
  end

  context "client is not set" do
    before do
      user.update_attribute(:client_slug, '')
    end

    it "should not explode" do
      visit '/proposals'
      expect(page).to have_content(default.public_identifier)
      expect(page).to have_content(ncr.public_identifier)
      expect(page).to have_content(gsa18f.proposal.public_identifier)
    end

    it "should show requester" do
      visit '/proposals'
      expect(page).to have_content("Requester")
      expect(page).to have_content(default.name+' '+default.requester.email_address)
    end
  end

  context "client is ncr" do
    before do
      user.update_attribute(:client_slug, 'ncr')
    end

    it "should not explode" do
      visit '/proposals'
      expect(page).to have_content(default.public_identifier)
      expect(page).to have_content(ncr.public_identifier)
      expect(page).to have_content(gsa18f.proposal.public_identifier)
    end

    it "should show requester" do
      visit '/proposals'
      expect(page).to have_content("Requester")
      expect(page).to have_content(ncr.name+' '+ncr.requester.email_address)
    end
  end

  context "client is gsa18f" do
    before do
      user.update_attribute(:client_slug, 'gsa18f')
    end

    it "should not explode" do
      visit '/proposals'
      expect(page).to have_content(default.public_identifier)
      expect(page).to have_content(ncr.public_identifier)
      expect(page).to have_content(gsa18f.proposal.public_identifier)
    end

    it "should show requester" do
      visit '/proposals'
      expect(page).to have_content("Requester")
      expect(page).to have_content(gsa18f.name+' '+gsa18f.requester.email_address)
    end
  end
end
