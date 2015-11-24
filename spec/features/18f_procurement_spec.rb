describe "GSA 18f Purchase Request Form" do
  it "requires sign-in" do
    visit '/gsa18f/procurements/new'
    expect(current_path).to eq('/')
    expect(page).to have_content("You need to sign in")
  end

  let(:requester) { create(:user, client_slug: "gsa18f") }
  let(:approver)  { Gsa18f::Procurement.user_with_role("gsa18f_approver") }
  let(:purchaser) { Gsa18f::Procurement.user_with_role("gsa18f_purchaser") }
  let(:procurement) do
    pr = create(:gsa18f_procurement, requester: requester)
    pr.add_steps
    pr
  end
  let(:proposal) { procurement.proposal }

  context "when signed in as the requester" do
    before do
      login_as(requester)
    end

    it "saves a Proposal with the attributes" do
      expect(Dispatcher).to receive(:deliver_new_proposal_emails)

      visit '/gsa18f/procurements/new'
      fill_in "Product name and description", with: "buying stuff"
      fill_in 'Justification', with: "because I need it"
      fill_in "Link to product", with: "http://www.amazon.com"
      fill_in 'Cost per unit', with: 123.45
      fill_in 'Quantity', with: 6
      fill_in 'gsa18f_procurement_date_requested', with: '12/12/2999'
      fill_in 'gsa18f_procurement_additional_info', with: 'none'
      select Gsa18f::Procurement::URGENCY[10], :from => 'gsa18f_procurement_urgency'
      select Gsa18f::Procurement::OFFICES[0], :from => 'gsa18f_procurement_office'
      expect {
        click_on 'Submit for approval'
      }.to change { Proposal.count }.from(0).to(1)

      expect(page).to have_content("Proposal submitted")
      expect(current_path).to eq("/proposals/#{Proposal.last.id}")

      proposal = Proposal.last
      expect(proposal.name).to eq("buying stuff")
      expect(proposal.flow).to eq('linear')
      expect(proposal.client_slug).to eq('gsa18f')
      expect(proposal.requester).to eq(requester)
      expect(proposal.approvers.map(&:email_address)).to eq([approver.email_address, purchaser.email_address])

      procurement = proposal.client_data
      expect(procurement.link_to_product).to eq('http://www.amazon.com')
      expect(procurement.date_requested.strftime('%m/%d/%Y')).to eq('12/12/2999')
      expect(procurement.additional_info).to eq('none')
      expect(procurement.cost_per_unit).to eq(123.45)
      expect(procurement.quantity).to eq(6)
      expect(procurement.office).to eq(Gsa18f::Procurement::OFFICES[0])
      expect(procurement.urgency).to eq(10)
    end

    it "does not set an observer" do
      expect(procurement.observers.map(&:email_address)).to be_empty
    end

    it "doesn't save when the amount is too high" do
      visit '/gsa18f/procurements/new'
      fill_in "Product name and description", with: "buying stuff"
      fill_in 'Quantity', with: 1
      fill_in 'Cost per unit', with: 10_000

      expect {
        click_on 'Submit for approval'
      }.to_not change { Proposal.count }

      expect(current_path).to eq('/gsa18f/procurements')
      expect(page).to have_content("Cost per unit must be less than or equal to $")
      # keeps the form values
      expect(find_field('Cost per unit').value).to eq('10000')
    end

    it "doesn't save when no quantity is requested" do
      visit '/gsa18f/procurements/new'
      fill_in "Product name and description", with: "buying stuff"
      fill_in 'Quantity', with: 0
      fill_in 'Cost per unit', with: 100.00

      expect {
        click_on "Submit for approval"
      }.to_not change { Proposal.count }

      expect(current_path).to eq('/gsa18f/procurements')
      expect(page).to have_content("Quantity must be greater than or equal to 1")
      # keeps the form values
    end

    it "can be restarted if pending" do
      visit "/gsa18f/procurements/#{procurement.id}/edit"
      fill_in "Link to product", with: "http://www.submitted.com"
      fill_in 'Cost per unit', with: 123.45
      fill_in 'Quantity', with: 1
      fill_in "Product name and description", with: 'resubmitted'
      click_on 'Update'
      expect(current_path).to eq("/proposals/#{proposal.id}")
      expect(page).to have_content("http://www.submitted.com")
      expect(page).to have_content("resubmitted")
      # Verify it is actually saved
      procurement.reload
      expect(procurement.link_to_product).to eq('http://www.submitted.com')
    end

    it "cannot be restarted if approved" do
      proposal.update_attributes(status: 'approved')  # avoid workflow

      visit "/gsa18f/procurements/#{procurement.id}/edit"
      expect(current_path).to eq("/gsa18f/procurements/new")
      expect(page).to have_content('already approved')
    end

    it "cannot be edited by someone other than the requester" do
      procurement.set_requester(create(:user))

      visit "/gsa18f/procurements/#{procurement.id}/edit"
      expect(current_path).to eq("/gsa18f/procurements/new")
      expect(page).to have_content('You are not the requester')
    end

    it "shows a restart link from a pending proposal" do
      visit "/proposals/#{proposal.id}"
      expect(page).to have_content('Modify Request')
      click_on('Modify Request')
      expect(current_path).to eq("/gsa18f/procurements/#{procurement.id}/edit")
    end

    it "saves all attributes when editing" do
      visit '/gsa18f/procurements/new'
      fill_in "Product name and description", with: "buying stuff"
      fill_in 'Justification', with: "because I need it"
      fill_in "Link to product", with: "http://www.amazon.com"
      fill_in 'Cost per unit', with: 123.45
      fill_in 'Quantity', with: 6
      fill_in 'gsa18f_procurement_date_requested', with: '12/12/2999'
      fill_in 'gsa18f_procurement_additional_info', with: 'none'
      select Gsa18f::Procurement::URGENCY[10], :from => 'gsa18f_procurement_urgency'
      select Gsa18f::Procurement::OFFICES[0], :from => 'gsa18f_procurement_office'

      click_on 'Submit for approval'

      expect(page).to have_content("Proposal submitted")
      expect(current_path).to eq("/proposals/#{Proposal.last.id}")
      expect(page).to have_content('Modify Request')

      click_on('Modify Request')
      expect(current_path).to eq("/gsa18f/procurements/#{Gsa18f::Procurement.last.id}/edit")

      click_on 'Update'

      proposal = Proposal.last
      expect(proposal.name).to eq("buying stuff")
      expect(proposal.flow).to eq('linear')

      procurement = proposal.client_data
      expect(procurement.link_to_product).to eq('http://www.amazon.com')
      expect(procurement.date_requested.strftime('%m/%d/%Y')).to eq('12/12/2999')
      expect(procurement.additional_info).to eq('none')
      expect(procurement.cost_per_unit).to eq(123.45)
      expect(procurement.quantity).to eq(6)
      expect(procurement.office).to eq(Gsa18f::Procurement::OFFICES[0])
      expect(procurement.urgency).to eq(10)

      expect(proposal.requester).to eq(requester)
      expect(proposal.approvers.map(&:email_address)).to eq([approver.email_address, purchaser.email_address])
    end

    it "has 'Discard Changes' link" do
      visit "/gsa18f/procurements/#{procurement.id}/edit"
      expect(page).to have_content("Discard Changes")
      click_on "Discard Changes"
      expect(current_path).to eq("/proposals/#{proposal.id}")
    end

    it "does not show a restart link for an approved proposal" do
      proposal.update_attribute(:status, 'approved') # avoid state machine

      visit "/proposals/#{proposal.id}"
      expect(page).not_to have_content('Modify Request')
    end

    it "does not show a restart link for another client" do
      proposal.client_data = nil
      proposal.save()
      visit "/proposals/#{proposal.id}"
      expect(page).not_to have_content('Modify Request')
    end

    it "does not show a restart link for non requester" do
      procurement.set_requester(create(:user))
      visit "/proposals/#{proposal.id}"
      expect(page).not_to have_content('Modify Request')
    end
  end

  context "when signed in as the approver" do
    before do
      login_as(approver)
    end

    it "the step execution button is correctly marked" do
      visit proposal_path(proposal)
      expect(page).to have_button('Approve')
    end

    it "shows a cancel link for approver" do
      visit proposal_path(proposal)
      expect(page).to have_content('Cancel this request')
    end 
  end

  context "when signed in as the purchaser" do
    before do
      login_as(purchaser)
    end

    it "the step execution button is correctly marked" do
      login_as(approver)
      visit "/proposals/#{proposal.id}"
      click_on 'Approve'
      login_as(purchaser)
      visit "/proposals/#{proposal.id}"
      expect(page).to have_button('Mark as Purchased')
    end

    it "does not show a cancel link for purchaser" do
      visit proposal_path(proposal)
      expect(page).to_not have_content('Cancel this request')
    end
  end
end
