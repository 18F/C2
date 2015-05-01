describe "GSA 18f Purchase Request Form" do
  it "requires sign-in" do
    visit '/gsa18f/procurements/new'
    expect(current_path).to eq('/')
    expect(page).to have_content("You need to sign in")
  end

  context "when signed in" do
    let(:requester) { FactoryGirl.create(:user) }
    let(:gsa18f) {
      pr = FactoryGirl.create(:gsa18f_procurement)
      pr.init_and_save_cart(requester)
      pr
    }
    let(:gsa18f_cart) {
      gsa18f.proposal.cart
    }

    before do
      login_as(requester)
    end

    it "saves a Cart with the attributes" do
      expect(Dispatcher).to receive(:deliver_new_proposal_emails)

      visit '/gsa18f/procurements/new'
      fill_in "Product Name and Description", with: "buying stuff"
      fill_in 'Justification', with: "because I need it"
      fill_in "Link to product", with: "http://www.amazon.com"
      fill_in 'Cost per unit', with: 123.45
      fill_in 'Quantity', with: 6
      fill_in 'gsa18f_procurement_date_requested', with: '12/12/2999'
      fill_in 'gsa18f_procurement_additional_info', with: 'none'
      select Gsa18f::Procurement::URGENCY[0], :from => 'gsa18f_procurement_urgency'
      select Gsa18f::Procurement::OFFICES[0], :from => 'gsa18f_procurement_office'
      expect {
        click_on 'Submit for approval'
      }.to change { Cart.count }.from(0).to(1)

      expect(page).to have_content("Procurement submitted")
      expect(current_path).to eq("/proposals/#{Proposal.last.id}")

      cart = Cart.last
      expect(cart.proposal.name).to eq("buying stuff")
      expect(cart.flow).to eq('linear')
      client_data = cart.proposal.client_data
      expect(client_data.client).to eq('gsa18f')
      expect(client_data.link_to_product).to eq('http://www.amazon.com')
      expect(client_data.date_requested).to eq('12/12/2999')
      expect(client_data.additional_info).to eq('none')
      # TODO should this persist as a number?
      expect(client_data.cost_per_unit).to eq(123.45)
      expect(client_data.quantity).to eq(6)
      expect(client_data.office).to eq(Gsa18f::Procurement::OFFICES[0])
      expect(client_data.urgency).to eq(Gsa18f::Procurement::URGENCY[0])
      expect(cart.requester).to eq(requester)
      expect(cart.approvers.map(&:email_address)).to eq(%w(
        18fapprover@gsa.gov
      ))
    end

    it "doesn't save when the amount is too high" do
      visit '/gsa18f/procurements/new'
      fill_in "Product Name and Description", with: "buying stuff"
      fill_in 'Quantity', with: 1
      fill_in 'Cost per unit', with: 10_000

      expect {
        click_on 'Submit for approval'
      }.to_not change { Cart.count }

      expect(current_path).to eq('/gsa18f/procurements')
      expect(page).to have_content("Cost per unit must be less than or equal to 3000")
      # keeps the form values
      expect(find_field('Cost per unit').value).to eq('10000')
    end

    it "doesn't save when no quantity is requested" do
      visit '/gsa18f/procurements/new'
      fill_in "Product Name and Description", with: "buying stuff"
      fill_in 'Quantity', with: 0
      fill_in 'Cost per unit', with: 100.00

      expect {
        click_on "Submit for approval"
      }.to_not change { Cart.count }

      expect(current_path).to eq('/gsa18f/procurements')
      expect(page).to have_content("Quantity must be greater than or equal to 1")
      # keeps the form values
    end

    it "can be restarted if pending" do
      visit "/gsa18f/procurements/#{gsa18f.id}/edit"
      fill_in "Link to product", with: "http://www.submitted.com"
      fill_in 'Cost per unit', with: 123.45
      fill_in 'Quantity', with: 1
      fill_in "Product Name and Description", with: 'resubmitted'
      click_on 'Submit for approval'
      expect(current_path).to eq("/proposals/#{gsa18f.proposal.id}")
      expect(page).to have_content("http://www.submitted.com")
      expect(page).to have_content("resubmitted")
      # Verify it is actually saved
      gsa18f.reload
      expect(gsa18f.link_to_product).to eq('http://www.submitted.com')
    end

    it "can be restarted if rejected" do
      gsa18f.proposal.update_attributes(status: 'rejected')  # avoid workflow

      visit "/gsa18f/procurements/#{gsa18f.id}/edit"
      expect(current_path).to eq("/gsa18f/procurements/#{gsa18f.id}/edit")
    end

    it "cannot be restarted if approved" do
      gsa18f_cart.proposal.update_attributes(status: 'approved')  # avoid workflow

      visit "/gsa18f/procurements/#{gsa18f.id}/edit"
      expect(current_path).to eq("/gsa18f/procurements/new")
      expect(page).to have_content('already approved')
    end

    it "cannot be edited by someone other than the requester" do
      gsa18f_cart.set_requester(FactoryGirl.create(:user))

      visit "/gsa18f/procurements/#{gsa18f.id}/edit"
      expect(current_path).to eq("/gsa18f/procurements/new")
      expect(page).to have_content('cannot restart')
    end

    it "shows a restart link from a pending cart" do
      visit "/proposals/#{gsa18f.proposal.id}"
      expect(page).to have_content('Modify Request')
      click_on('Modify Request')
      expect(current_path).to eq("/gsa18f/procurements/#{gsa18f.id}/edit")
    end

    it "saves all attributes when editing" do
      visit '/gsa18f/procurements/new'
      fill_in "Product Name and Description", with: "buying stuff"
      fill_in 'Justification', with: "because I need it"
      fill_in "Link to product", with: "http://www.amazon.com"
      fill_in 'Cost per unit', with: 123.45
      fill_in 'Quantity', with: 6
      fill_in 'gsa18f_procurement_date_requested', with: '12/12/2999'
      fill_in 'gsa18f_procurement_additional_info', with: 'none'
      select Gsa18f::Procurement::URGENCY[0], :from => 'gsa18f_procurement_urgency'
      select Gsa18f::Procurement::OFFICES[0], :from => 'gsa18f_procurement_office'

      click_on 'Submit for approval'

      expect(page).to have_content("Procurement submitted")
      expect(current_path).to eq("/proposals/#{Proposal.last.id}")
      expect(page).to have_content('Modify Request')

      click_on('Modify Request')
      expect(current_path).to eq("/gsa18f/procurements/#{Gsa18f::Procurement.last.id}/edit")

      click_on 'Submit for approval'

      cart = Cart.last
      client_data = cart.proposal.client_data

      expect(cart.proposal.name).to eq("buying stuff")
      expect(cart.flow).to eq('linear')
      expect(client_data.link_to_product).to eq('http://www.amazon.com')
      expect(client_data.date_requested).to eq('12/12/2999')
      expect(client_data.additional_info).to eq('none')
      # TODO should this persist as a number?
      expect(client_data.cost_per_unit).to eq(123.45)
      expect(client_data.quantity).to eq(6)
      expect(client_data.office).to eq(Gsa18f::Procurement::OFFICES[0])
      expect(client_data.urgency).to eq(Gsa18f::Procurement::URGENCY[0])
      expect(cart.requester).to eq(requester)
      expect(cart.approvers.map(&:email_address)).to eq(%w(
        18fapprover@gsa.gov
      ))
    end

    it "shows a restart link from a rejected cart" do
      gsa18f_cart.proposal.update_attribute(:status, 'rejected') # avoid state machine

      visit "/proposals/#{gsa18f.proposal.id}"
      expect(page).to have_content('Modify Request')
    end

    it "does not show a restart link for an approved cart" do
      gsa18f_cart.proposal.update_attribute(:status, 'approved') # avoid state machine

      visit "/proposals/#{gsa18f.proposal.id}"
      expect(page).not_to have_content('Modify Request')
    end

    it "does not show a restart link for another client" do
      gsa18f_cart.proposal.client_data = nil
      gsa18f_cart.proposal.save()
      visit "/proposals/#{gsa18f.proposal.id}"
      expect(page).not_to have_content('Modify Request')
    end

    it "does not show a restart link for non requester" do
      gsa18f_cart.set_requester(FactoryGirl.create(:user))
      visit "/proposals/#{gsa18f.proposal.id}"
      expect(page).not_to have_content('Modify Request')
    end
  end
end
