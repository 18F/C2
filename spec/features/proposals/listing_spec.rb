describe "Listing Page", test_client_request: true do
  shared_examples "listing page" do
    it "shows user's Proposals from all clients" do
      create_records
      login_as(user)

      visit proposals_path

      expect(page).to have_content(default.public_id)
      expect(page).to have_content(ncr.proposal.public_id)
      expect(page).to have_content(gsa18f.proposal.public_id)
    end
  end

  context "client is not set" do
    it_behaves_like "listing page"

    it "should show requester" do
      user.update(client_slug: '')
      create_records
      login_as(user)

      visit proposals_path
      expect(page).to have_content("Requester")
      expect(page).to have_content("#{default.name} #{default.requester.email_address}")
    end

    it "should list the proposal in the proper section" do
      user.update(client_slug: '')
      create_records
      proposal = Proposal.last
      proposal.update(status: 'approved')

      login_as(user)
      visit proposals_path

      expect(page).not_to have_content("Cancelled Purchase Requests")

      proposal.update(status: 'cancelled')

      visit proposals_path
      expect(page).to have_content("No recently completed purchase requests")
    end
  end

  Proposal.client_slugs.each do |client_slug|
    context "client is #{client_slug}" do
      let(:client_model) { send(client_slug) }

      it_behaves_like "listing page"

      it "should show requester" do
        user.update(client_slug: client_slug)
        create_records
        login_as(user)

        visit proposals_path

        expect(page).to have_content("Requester")
        expect(page).to have_content client_model.requester.email_address
        expect(page).to have_content client_model.proposal.name
      end
    end
  end

  private

  def user
    @_user ||= create(:user)
  end

  def create_records
    default
    ncr
    gsa18f
    test
  end

  def default
    @_default ||= create(:proposal, requester: user)
  end

  def ncr
    @_ncr ||= create(:ncr_work_order, requester: user)
  end

  def gsa18f
    @_gsa18f ||= create(:gsa18f_procurement, requester: user)
  end

  def test
    @_test_client_request ||= create(:test_client_request, requester: user)
  end
end
