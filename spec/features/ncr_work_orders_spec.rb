describe "National Capital Region proposals" do
  it "requires sign-in" do
    visit '/ncr/work_orders/new'
    expect(current_path).to eq('/')
    expect(page).to have_content("You need to sign in")
  end

  context "when signed in as the requester" do
    let(:requester) { FactoryGirl.create(:user) }

    before do
      login_as(requester)
    end

    it "saves a Proposal with the attributes" do
      expect(Dispatcher).to receive(:deliver_new_proposal_emails)

      visit '/ncr/work_orders/new'
      fill_in 'Project title', with: "buying stuff"
      fill_in 'Description', with: "desc content"
      choose 'BA80'
      fill_in 'Vendor', with: 'ACME'
      fill_in 'Amount', with: 123.45
      fill_in "Approving Official's Email Address", with: 'approver@example.com'
      select Ncr::BUILDING_NUMBERS[0], :from => 'ncr_work_order_building_number'
      select Ncr::OFFICES[0], :from => 'ncr_work_order_office'
      expect {
        click_on 'Submit for approval'
      }.to change { Proposal.count }.from(0).to(1)

      proposal = Proposal.last.as_subclass
      expect(page).to have_content("Proposal submitted")
      expect(current_path).to eq("/proposals/#{proposal.id}")

      expect(proposal.name).to eq("buying stuff")
      expect(proposal.flow).to eq('linear')
      expect(proposal.client).to eq('ncr')
      expect(proposal.expense_type).to eq('BA80')
      expect(proposal.vendor).to eq('ACME')
      expect(proposal.amount).to eq(123.45)
      expect(proposal.building_number).to eq(Ncr::BUILDING_NUMBERS[0])
      expect(proposal.office).to eq(Ncr::OFFICES[0])
      expect(proposal.description).to eq('desc content')
      expect(proposal.requester).to eq(requester)
      expect(proposal.approvers.map(&:email_address)).to eq(%w(
        approver@example.com
        communicart.budget.approver@gmail.com
      ))
    end

    it "defaults to the approver from the last request" do
      proposal = FactoryGirl.create(:proposal, :with_cart, :with_approvers,
                                    requester: requester)
      visit '/ncr/work_orders/new'
      expect(find_field("Approving Official's Email Address").value).to eq(
        proposal.approvers.first.email_address)
    end

    it "doesn't save when the amount is too high" do
      visit '/ncr/work_orders/new'
      fill_in 'Project title', with: "buying stuff"
      choose 'BA80'
      fill_in 'Vendor', with: 'ACME'
      fill_in 'Amount', with: 10_000

      expect {
        click_on 'Submit for approval'
      }.to_not change { Proposal.count }

      expect(current_path).to eq('/ncr/work_orders')
      expect(page).to have_content("Amount must be less than or equal to 3000")
      # keeps the form values
      expect(find_field('Amount').value).to eq('10000.0')
    end

    it "includes has overwritten field names" do
      visit '/ncr/work_orders/new'
      fill_in 'Project title', with: "buying stuff"
      choose 'BA80'
      fill_in 'RWA Number', with: 'B9876543'
      fill_in 'Vendor', with: 'ACME'
      fill_in 'Amount', with: 123.45
      fill_in "Approving Official's Email Address", with: 'approver@example.com'
      select Ncr::BUILDING_NUMBERS[0], :from => 'ncr_work_order_building_number'
      select Ncr::OFFICES[0], :from => 'ncr_work_order_office'
      click_on 'Submit for approval'
      expect(current_path).to eq("/proposals/#{Proposal.last.id}")
      expect(page).to have_content("RWA Number")
    end

    it "hides fields based on expense", :js => true do
      visit '/ncr/work_orders/new'
      expect(page).to have_no_field("RWA Number")
      expect(page).to have_no_field("Work Order")
      expect(page).to have_no_field("emergency")
      choose 'BA61'
      expect(page).to have_no_field("RWA Number")
      expect(page).to have_no_field("Work Order")
      expect(page).to have_field("emergency")
      expect(find_field("emergency", visible: false)).to be_visible
      choose 'BA80'
      expect(page).to have_field("RWA Number")
      expect(page).to have_field("Work Order")
      expect(page).to have_no_field("emergency")
      expect(find_field("RWA Number")).to be_visible
    end

    let (:work_order) { 
      wo = FactoryGirl.create(:ncr_work_order, requester: requester)
      wo.add_approvals('approver@example.com')
      wo
    }
    it "can be edited if pending" do
      visit "/ncr/work_orders/#{work_order.id}/edit"
      expect(find_field("ncr_work_order_building_number").value).to eq(
        Ncr::BUILDING_NUMBERS[0])
      fill_in 'Vendor', with: 'New ACME'
      click_on 'Submit for approval'
      expect(current_path).to eq("/proposals/#{work_order.id}")
      expect(page).to have_content("New ACME")
      expect(page).to have_content("resubmitted")
      # Verify it is actually saved
      work_order.reload
      expect(work_order.vendor).to eq("New ACME")
    end

    it "has a disabled field if first approval is done" do
      visit "/ncr/work_orders/#{work_order.id}/edit"
      expect(find("[name=approver_email]")["disabled"]).to be_nil
      work_order.approvals.first.approve!
      visit "/ncr/work_orders/#{work_order.id}/edit"
      expect(find("[name=approver_email]")["disabled"]).to eq("disabled")
      # And we can still submit
      fill_in 'Vendor', with: 'New ACME'
      click_on 'Submit for approval'
      expect(current_path).to eq("/proposals/#{work_order.id}")
      # Verify it is actually saved
      work_order.reload
      expect(work_order.vendor).to eq("New ACME")
    end

    it "can be edited if rejected" do
      work_order.update_attributes(status: 'rejected')  # avoid workflow

      visit "/ncr/work_orders/#{work_order.id}/edit"
      expect(current_path).to eq("/ncr/work_orders/#{work_order.id}/edit")
    end

    it "cannot be edited if approved" do
      work_order.update_attributes(status: 'approved')  # avoid workflow

      visit "/ncr/work_orders/#{work_order.id}/edit"
      expect(current_path).to eq("/ncr/work_orders/new")
      expect(page).to have_content('already approved')
    end

    it "cannot be edited by someone other than the requester" do
      work_order.set_requester(FactoryGirl.create(:user))

      visit "/ncr/work_orders/#{work_order.id}/edit"
      expect(current_path).to eq("/ncr/work_orders/new")
      expect(page).to have_content('not the requester')
    end

    it "shows a edit link from a pending cart" do
      visit "/proposals/#{work_order.id}"
      expect(page).to have_content('Modify Request')
      click_on('Modify Request')
      expect(current_path).to eq("/ncr/work_orders/#{work_order.id}/edit")
    end

    it "shows a edit link from a rejected cart" do
      work_order.update_attribute(:status, 'rejected') # avoid state machine

      visit "/proposals/#{work_order.id}"
      expect(page).to have_content('Modify Request')
    end

    it "does not show a edit link for an approved cart" do
      work_order.update_attribute(:status, 'approved') # avoid state machine

      visit "/proposals/#{work_order.id}"
      expect(page).not_to have_content('Modify Request')
    end

    it "does not show a edit link for another client" do
      work_order.update_attribute(:subclass, nil)
      visit "/proposals/#{work_order.id}"
      expect(page).not_to have_content('Modify Request')
    end

    it "does not show a edit link for non requester" do
      work_order.set_requester(FactoryGirl.create(:user))
      visit "/proposals/#{work_order.id}"
      expect(page).not_to have_content('Modify Request')
    end

    context "selected common values on proposal page" do
      before do
        visit '/ncr/work_orders/new'

        fill_in 'Project title', with: "buying stuff"
        fill_in 'Vendor', with: 'ACME'
        fill_in 'Amount', with: 123.45
        fill_in "Approving Official's Email Address", with: 'approver@example.com'
        select Ncr::BUILDING_NUMBERS[0], :from => 'ncr_work_order_building_number'
        select Ncr::OFFICES[0], :from => 'ncr_work_order_office'
      end

      it "approves emergencies" do
        choose 'BA61'
        check "This request was an emergency and I received a verbal Notice to Proceed (NTP)"
        expect {
          click_on 'Submit for approval'
        }.to change { Proposal.count }.from(0).to(1)

        proposal = Proposal.last.as_subclass
        expect(page).to have_content("Proposal submitted")
        expect(current_path).to eq("/proposals/#{proposal.id}")
        expect(page).to have_content("0 of 0 approved")

        expect(proposal.emergency).to eq(true)
        expect(proposal.approved?).to eq(true)
      end

      it "does not set emergencies if form type changes" do
        choose 'BA61'
        check "This request was an emergency and I received a verbal Notice to Proceed (NTP)"
        choose 'BA80'
        fill_in 'RWA Number', with: 'R9876543'
        expect {
          click_on 'Submit for approval'
        }.to change { Proposal.count }.from(0).to(1)

        proposal = Proposal.last.as_subclass
        expect(page).to have_content("Proposal submitted")
        expect(current_path).to eq("/proposals/#{proposal.id}")

        expect(proposal.emergency).to eq(false)
        expect(proposal.approved?).to eq(false)
      end
    end
  end
end
