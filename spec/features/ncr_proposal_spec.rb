describe "National Capital Region proposals" do
  it "requires sign-in" do
    visit '/ncr/proposals/new'
    expect(current_path).to eq('/')
    expect(page).to have_content("You need to sign in")
  end

  context "when signed in" do
    let(:requester) { FactoryGirl.create(:user) }
    let(:ncr_cart) {
      proposal = FactoryGirl.build(:proposal_form)
      proposal.requester = requester
      proposal.create_cart
    }

    before do
      login_as(requester)
    end

    it "saves a Cart with the attributes" do
      expect(Dispatcher).to receive(:deliver_new_cart_emails)

      visit '/ncr/proposals/new'
      fill_in 'Description', with: "buying stuff"
      choose 'BA80'
      fill_in 'Vendor', with: 'ACME'
      fill_in 'Amount', with: 123.45
      fill_in "Approving Official's Email Address", with: 'approver@example.com'
      select 'Entire Jackson Place Complex', :from => 'ncr_proposal_building_number'
      select Ncr::ProposalForm::OFFICES[0], :from => 'ncr_proposal_office'
      expect {
        click_on 'Submit for approval'
      }.to change { Cart.count }.from(0).to(1)

      expect(page).to have_content("Proposal submitted")
      expect(current_path).to eq("/carts/#{Cart.last.id}")

      cart = Cart.last
      expect(cart.name).to eq("buying stuff")
      expect(cart.flow).to eq('linear')
      expect(cart.getProp(:origin)).to eq('ncr')
      expect(cart.getProp(:expense_type)).to eq('BA80')
      expect(cart.getProp(:vendor)).to eq('ACME')
      # TODO should this persist as a number?
      expect(cart.getProp(:amount)).to eq("123.45")
      expect(cart.getProp(:building_number)).to eq('Entire Jackson Place Complex')
      expect(cart.getProp(:office)).to eq(Ncr::ProposalForm::OFFICES[0])
      expect(cart.requester).to eq(requester)
      expect(cart.approvers.map(&:email_address)).to eq(%w(
        approver@example.com
        communicart.budget.approver@gmail.com
      ))
    end

    it "defaults to the approver from the last request" do
      cart = FactoryGirl.create(:cart_with_approvals)
      cart.set_requester(requester)

      visit '/ncr/proposals/new'
      expect(find_field("Approving Official's Email Address").value).to eq('approver1@some-dot-gov.gov')
    end

    it "doesn't save when the amount is too high" do
      visit '/ncr/proposals/new'
      fill_in 'Description', with: "buying stuff"
      choose 'BA80'
      fill_in 'Vendor', with: 'ACME'
      fill_in 'Amount', with: 10_000

      expect {
        click_on 'Submit for approval'
      }.to_not change { Cart.count }

      expect(current_path).to eq('/ncr/proposals')
      expect(page).to have_content("Amount must be less than or equal to 3000")
      # keeps the form values
      expect(find_field('Amount').value).to eq('10000')
    end

    it "includes has overwritten field names" do
      visit '/ncr/proposals/new'
      expect(page).to have_content("RWA Number")
      fill_in 'Description', with: "buying stuff"
      choose 'BA80'
      fill_in 'RWA Number', with: 'NumNum', disabled: true
      fill_in 'Vendor', with: 'ACME'
      fill_in 'Amount', with: 123.45
      fill_in "Approving Official's Email Address", with: 'approver@example.com'
      select 'Entire Jackson Place Complex', :from => 'ncr_proposal_building_number'
      select Ncr::ProposalForm::OFFICES[0], :from => 'ncr_proposal_office'
      click_on 'Submit for approval'
      expect(current_path).to eq("/carts/#{Cart.last.id}")
      expect(page).to have_content("RWA Number")
    end

    it "can be restarted if pending" do
      visit "/ncr/proposals/#{ncr_cart.id}/edit"
      expect(find_field("ncr_proposal_building_number").value).to eq(
        'Entire WH Complex')
      fill_in 'Vendor', with: 'ACME'
      click_on 'Submit for approval'
      expect(current_path).to eq("/carts/#{ncr_cart.id}")
      expect(page).to have_content("ACME")
      expect(page).to have_content("resubmitted")
      # Verify it is actually saved
      ncr_cart.reload
      expect(ncr_cart.getProp('vendor')).to eq('ACME')
    end

    it "can be restarted if rejected" do
      ncr_cart.proposal.update_attributes(status: 'rejected')  # avoid workflow

      visit "/ncr/proposals/#{ncr_cart.id}/edit"
      expect(current_path).to eq("/ncr/proposals/#{ncr_cart.id}/edit")
    end

    it "cannot be restarted if approved" do
      ncr_cart.proposal.update_attributes(status: 'approved')  # avoid workflow

      visit "/ncr/proposals/#{ncr_cart.id}/edit"
      expect(current_path).to eq("/ncr/proposals/new")
      expect(page).to have_content('already approved')
    end

    it "cannot be edited by someone other than the requester" do
      req = ncr_cart.approvals.where(role: 'requester').first
      req.update_attribute(:user, FactoryGirl.create(:user))

      visit "/ncr/proposals/#{ncr_cart.id}/edit"
      expect(current_path).to eq("/ncr/proposals/new")
      expect(page).to have_content('cannot restart')
    end

    it "shows a restart link from a pending cart" do
      ncr_cart.setProp('origin', 'ncr')

      visit "/carts/#{ncr_cart.id}"
      expect(page).to have_content('Restart this Cart?')
      click_on('Restart this Cart?')
      expect(current_path).to eq("/ncr/proposals/#{ncr_cart.id}/edit")
    end

    it "shows a restart link from a rejected cart" do
      ncr_cart.setProp('origin', 'ncr')
      ncr_cart.proposal.update_attribute(:status, 'rejected') # avoid state machine

      visit "/carts/#{ncr_cart.id}"
      expect(page).to have_content('Restart this Cart?')
    end

    it "does not show a restart link for an approved cart" do
      ncr_cart.setProp('origin', 'ncr')
      ncr_cart.proposal.update_attribute(:status, 'approved') # avoid state machine

      visit "/carts/#{ncr_cart.id}"
      expect(page).not_to have_content('Restart this Cart?')
    end

    it "does not show a restart link for another client" do
      ncr_cart.setProp('origin', 'somewhereElse')
      visit "/carts/#{ncr_cart.id}"
      expect(page).not_to have_content('Restart this Cart?')
    end

    it "does not show a restart link for non requester" do
      req = ncr_cart.approvals.where(role: 'requester').first
      req.update_attribute(:user, FactoryGirl.create(:user))

      visit "/carts/#{ncr_cart.id}"
      expect(page).not_to have_content('Restart this Cart?')
    end
  end
end
