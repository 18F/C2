describe "Listing Page" do
  let!(:user){ create(:user, client_slug: "ncr") }
  let!(:default){ create(:proposal, requester: user) }
  let!(:ncr){
    ncr = create(:ncr_work_order)
    ncr.proposal.update_attribute(:requester, user)
    ncr
  }
  let!(:gsa18f){
    gsa18f = create(:gsa18f_procurement)
    gsa18f.proposal.update_attribute(:requester, user)
    gsa18f
  }
  let!(:test){
    test_client_request = create(:test_client_request)
    test_client_request.proposal.update_attribute(:requester, user)
    test_client_request
  }
  before do
    login_as(user)
  end

  shared_examples "listing page" do
    it "shows user's Proposals from all clients" do
      visit '/proposals'
      expect(page).to have_content(default.public_id)
      expect(page).to have_content(ncr.proposal.public_id)
      expect(page).to have_content(gsa18f.proposal.public_id)
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
      expect(page).to have_content("#{default.name} #{default.requester.email_address}")
    end
  end

  Proposal.client_slugs.each do |client_slug|
    context "client is #{client_slug}" do
      let(:client_model) { send(client_slug) }

      before do
        user.update_attribute(:client_slug, client_slug)
      end

      it_behaves_like "listing page"

      it "should show requester" do
        visit "/proposals"
        expect(page).to have_content("Requester")
        expect(page).to have_content client_model.requester.email_address
        expect(page).to have_content client_model.proposal.name
      end
    end
  end
end
