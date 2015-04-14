describe "GSA 18f Purchase Request Form" do
  it "requires sign-in" do
    visit '/gsa18f/proposals/new'
    expect(current_path).to eq('/')
    expect(page).to have_content("You need to sign in")
  end

  context "when signed in" do
    let(:requester) { FactoryGirl.create(:user) }
    let(:gsa18f) {
      proposal = FactoryGirl.build(:gsa18f_proposal_form)
      proposal.requester = requester
      proposal.create_cart
    }

    before do
      login_as(requester)
    end

    it "saves a Cart with the attributes" do
      expect(Dispatcher).to receive(:deliver_new_cart_emails)

      visit '/gsa18f/proposals/new'
      fill_in "Product Name and Description", with: "buying stuff"
      fill_in 'Justification', with: "because I need it"
      fill_in "Link to product", with: "http://www.amazon.com"
      fill_in 'Cost per unit', with: 123.45
      fill_in 'Quantity', with: 6
      fill_in 'gsa18f_proposal_date_requested', with: '12/12/2999'
      fill_in 'gsa18f_proposal_additional_info', with: 'none'
      select Gsa18f::ProposalForm::URGENCY[0], :from => 'gsa18f_proposal_urgency'
      select Gsa18f::ProposalForm::OFFICES[0], :from => 'gsa18f_proposal_office'
      expect {
        click_on 'Submit for approval'
      }.to change { Cart.count }.from(0).to(1)

      expect(page).to have_content("Proposal submitted")
      expect(current_path).to eq("/proposals/#{Proposal.last.id}")

      cart = Cart.last
      expect(cart.name).to eq("buying stuff")
      expect(cart.flow).to eq('linear')
      expect(cart.getProp(:origin)).to eq('gsa18f')
      expect(cart.getProp(:link_to_product)).to eq('http://www.amazon.com')
      expect(cart.getProp(:date_requested)).to eq('12/12/2999')
      expect(cart.getProp(:additional_info)).to eq('none')
      # TODO should this persist as a number?
      expect(cart.getProp(:cost_per_unit)).to eq('123.45')
      expect(cart.getProp(:quantity)).to eq('6')
      expect(cart.getProp(:office)).to eq(Gsa18f::ProposalForm::OFFICES[0])
      expect(cart.getProp(:urgency)).to eq(Gsa18f::ProposalForm::URGENCY[0])
      expect(cart.requester).to eq(requester)
      expect(cart.approvers.map(&:email_address)).to eq(%w(
        18fapprover@gsa.gov
      ))
    end

    it "doesn't save when the amount is too high" do
      visit '/gsa18f/proposals/new'
      fill_in "Product Name and Description", with: "buying stuff"
      fill_in 'Quantity', with: 1
      fill_in 'Cost per unit', with: 10_000

      expect {
        click_on 'Submit for approval'
      }.to_not change { Cart.count }

      expect(current_path).to eq('/gsa18f/proposals')
      expect(page).to have_content("Cost per unit must be less than or equal to 3000")
      # keeps the form values
      expect(find_field('Cost per unit').value).to eq('10000')
    end

    it "doesn't save when no quantity is requested" do
      visit '/gsa18f/proposals/new'
      fill_in "Product Name and Description", with: "buying stuff"
      fill_in 'Quantity', with: 0
      fill_in 'Cost per unit', with: 100.00

      expect {
        click_on "Submit for approval"
      }.to_not change { Cart.count }

      expect(current_path).to eq('/gsa18f/proposals')
      expect(page).to have_content("Quantity must be greater than or equal to 1")
      # keeps the form values
    end

    it "can be restarted if pending" do
      visit "/gsa18f/proposals/#{gsa18f.id}/edit"
      fill_in "Link to product", with: "http://www.submitted.com"
      fill_in 'Cost per unit', with: 123.45
      fill_in 'Quantity', with: 1
      fill_in "Product Name and Description", with: 'resubmitted'
      click_on 'Submit for approval'
      expect(current_path).to eq("/proposals/#{Cart.find(gsa18f.id).proposal_id}")
      expect(page).to have_content("http://www.submitted.com")
      expect(page).to have_content("resubmitted")
      # Verify it is actually saved
      gsa18f.reload
      expect(gsa18f.getProp('link_to_product')).to eq('http://www.submitted.com')
    end

    it "can be restarted if rejected" do
      gsa18f.proposal.update_attributes(status: 'rejected')  # avoid workflow

      visit "/gsa18f/proposals/#{gsa18f.id}/edit"
      expect(current_path).to eq("/gsa18f/proposals/#{gsa18f.id}/edit")
    end

    it "cannot be restarted if approved" do
      gsa18f.proposal.update_attributes(status: 'approved')  # avoid workflow

      visit "/gsa18f/proposals/#{gsa18f.id}/edit"
      expect(current_path).to eq("/gsa18f/proposals/new")
      expect(page).to have_content('already approved')
    end

    it "cannot be edited by someone other than the requester" do
      gsa18f.set_requester(FactoryGirl.create(:user))

      visit "/gsa18f/proposals/#{gsa18f.id}/edit"
      expect(current_path).to eq("/gsa18f/proposals/new")
      expect(page).to have_content('cannot restart')
    end

    it "shows a restart link from a pending cart" do
      gsa18f.setProp('origin', 'gsa18f')

      visit "/proposals/#{Cart.find(gsa18f.id).proposal_id}"
      expect(page).to have_content('Modify Request')
      click_on('Modify Request')
      expect(current_path).to eq("/gsa18f/proposals/#{gsa18f.id}/edit")
    end

    it "saves all attributes when editing" do
      visit '/gsa18f/proposals/new'
      fill_in "Product Name and Description", with: "buying stuff"
      fill_in 'Justification', with: "because I need it"
      fill_in "Link to product", with: "http://www.amazon.com"
      fill_in 'Cost per unit', with: 123.45
      fill_in 'Quantity', with: 6
      fill_in 'gsa18f_proposal_date_requested', with: '12/12/2999'
      fill_in 'gsa18f_proposal_additional_info', with: 'none'
      select Gsa18f::ProposalForm::URGENCY[0], :from => 'gsa18f_proposal_urgency'
      select Gsa18f::ProposalForm::OFFICES[0], :from => 'gsa18f_proposal_office'

      click_on 'Submit for approval'

      expect(page).to have_content("Proposal submitted")
      expect(current_path).to eq("/proposals/#{Proposal.last.id}")
      expect(page).to have_content('Modify Request')

      click_on('Modify Request')

      expect(current_path).to eq("/gsa18f/proposals/#{Cart.last.id}/edit")

      click_on 'Submit for approval'

      cart = Cart.last
      expect(cart.name).to eq("buying stuff")
      expect(cart.flow).to eq('linear')
      expect(cart.getProp(:origin)).to eq('gsa18f')
      expect(cart.getProp(:link_to_product)).to eq('http://www.amazon.com')
      expect(cart.getProp(:date_requested)).to eq('12/12/2999')
      expect(cart.getProp(:additional_info)).to eq('none')
      # TODO should this persist as a number?
      expect(cart.getProp(:cost_per_unit)).to eq('123.45')
      expect(cart.getProp(:quantity)).to eq('6')
      expect(cart.getProp(:office)).to eq(Gsa18f::ProposalForm::OFFICES[0])
      expect(cart.getProp(:urgency)).to eq(Gsa18f::ProposalForm::URGENCY[0])
      expect(cart.requester).to eq(requester)
      expect(cart.approvers.map(&:email_address)).to eq(%w(
        18fapprover@gsa.gov
      ))
    end

    it "shows a restart link from a rejected cart" do
      gsa18f.setProp('origin', 'gsa18f')
      gsa18f.proposal.update_attribute(:status, 'rejected') # avoid state machine

      visit "/proposals/#{Cart.find(gsa18f.id).proposal_id}"
      expect(page).to have_content('Modify Request')
    end

    it "does not show a restart link for an approved cart" do
      gsa18f.setProp('origin', 'gsa18f')
      gsa18f.proposal.update_attribute(:status, 'approved') # avoid state machine

      visit "/proposals/#{Cart.find(gsa18f.id).proposal_id}"
      expect(page).not_to have_content('Modify Request')
    end

    it "does not show a restart link for another client" do
      gsa18f.setProp('origin', 'somewhereElse')
      visit "/proposals/#{Cart.find(gsa18f.id).proposal_id}"
      expect(page).not_to have_content('Modify Request')
    end

    it "does not show a restart link for non requester" do
      gsa18f.set_requester(FactoryGirl.create(:user))
      visit "/proposals/#{Cart.find(gsa18f.id).proposal_id}"
      expect(page).not_to have_content('Modify Request')
    end
  end
end
