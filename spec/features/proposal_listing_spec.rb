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

  shared_examples "listing page" do
    it "shows user's Proposals from all clients" do
      visit '/proposals'
      expect(page).to have_content(default.public_identifier)
      expect(page).to have_content(ncr.public_identifier)
      expect(page).to have_content(gsa18f.proposal.public_identifier)
    end
  end

  context "client is not set" do
    before do
      user.update_attribute(:client_slug, '')
    end

    it_behaves_like "listing page"

    it "should show requester" do
      visit '/proposals'
      expect(page).to have_content("Requester")
      expect(page).to have_content(default.name+' '+default.requester.email_address)
    end

    it "should list the proposal in the proper section" do
      proposal = Proposal.last
      proposal.update_attribute(:status, 'approved')
      visit '/proposals'
      expect(page).not_to have_content("Cancelled Purchase Requests")

      proposal.update_attribute(:status, 'cancelled')
      visit '/proposals'
      expect(page).to have_content("No recently completed purchase requests")
    end
  end

  context "client is ncr" do
    before do
      user.update_attribute(:client_slug, 'ncr')
    end

    it_behaves_like "listing page"

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

    it_behaves_like "listing page"

    it "should show requester" do
      visit '/proposals'
      expect(page).to have_content("Requester")
      expect(page).to have_content(gsa18f.name+' '+gsa18f.requester.email_address)
    end
  end
end
