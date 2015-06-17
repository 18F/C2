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
      select Ncr::Organization.all[0], :from => 'ncr_work_order_org_code'
      expect {
        click_on 'Submit for approval'
      }.to change { Proposal.count }.from(0).to(1)

      proposal = Proposal.last
      expect(page).to have_content("Proposal submitted")
      expect(current_path).to eq("/proposals/#{proposal.id}")

      expect(proposal.name).to eq("buying stuff")
      expect(proposal.flow).to eq('linear')
      client_data = proposal.client_data
      expect(client_data.client).to eq('ncr')
      expect(client_data.expense_type).to eq('BA80')
      expect(client_data.vendor).to eq('ACME')
      expect(client_data.amount).to eq(123.45)
      expect(client_data.building_number).to eq(Ncr::BUILDING_NUMBERS[0])
      expect(client_data.org_code).to eq(Ncr::Organization.all[0])
      expect(client_data.description).to eq('desc content')
      expect(proposal.requester).to eq(requester)
      expect(proposal.approvers.map(&:email_address)).to eq(%w(
        approver@example.com
        communicart.budget.approver@gmail.com
      ))
    end

    it "defaults to the approver from the last request" do
      proposal = FactoryGirl.create(:proposal, :with_approvers,
                                    requester: requester)
      visit '/ncr/work_orders/new'
      expect(find_field("Approving Official's Email Address").value).to eq(
        proposal.approvers.first.email_address)
    end

    it "requires a project_title" do
      visit '/ncr/work_orders/new'
      expect {
        click_on 'Submit for approval'
      }.to_not change { Proposal.count }
      expect(page).to have_content("Project title can't be blank")
    end

    with_feature 'HIDE_BA61_OPTION' do
      it "removes the radio button" do
        visit '/ncr/work_orders/new'
        expect(page).to_not have_content('BA61')
      end

      it "defaults to BA80" do
        visit '/ncr/work_orders/new'
        fill_in 'Project title', with: "buying stuff"
        fill_in 'Description', with: "desc content"
        # no need to select BA80
        fill_in 'Vendor', with: 'ACME'
        fill_in 'Amount', with: 123.45
        fill_in "Approving Official's Email Address", with: 'approver@example.com'
        select Ncr::BUILDING_NUMBERS[0], :from => 'ncr_work_order_building_number'
        select Ncr::Organization.all[0], :from => 'ncr_work_order_org_code'
        expect {
          click_on 'Submit for approval'
        }.to change { Proposal.count }.from(0).to(1)

        proposal = Proposal.last
        expect(proposal.client_data.expense_type).to eq('BA80')
      end
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
      expect(page).to have_content("Amount must be less than or equal to $3,000")
      # keeps the form values
      expect(find_field('Amount').value).to eq('10000')
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
      select Ncr::Organization.all[0], :from => 'ncr_work_order_org_code'
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

    it "allows attachments to be added during intake without JS" do
      visit '/ncr/work_orders/new'
      expect(page).to have_content("Attachments")
      expect(page).not_to have_selector(".js-am-minus")
      expect(page).not_to have_selector(".js-am-plus")
      expect(page).to have_selector("input[type=file]", count: 10)
    end

    it "allows attachments to be added during intake with JS", :js => true do
      visit '/ncr/work_orders/new'
      expect(page).to have_content("Attachments")
      first_minus = find(".js-am-minus")
      first_plus = find(".js-am-plus")
      expect(first_minus).to be_visible
      expect(first_plus).to be_visible
      expect(first_minus).to be_disabled
      expect(find("input[type=file]")[:name]).to eq("attachments[]")
      first_plus.click    # Adds one row
      expect(page).to have_selector(".js-am-minus", count: 2)
      expect(page).to have_selector(".js-am-plus", count: 2)
      expect(page).to have_selector("input[type=file]", count: 2)
    end

    let (:work_order) {
      wo = FactoryGirl.create(:ncr_work_order, requester: requester)
      wo.add_approvals('approver@example.com')
      wo
    }
    let(:ncr_proposal) {
      work_order.proposal
    }
    it "can be edited if pending" do
      visit "/ncr/work_orders/#{work_order.id}/edit"
      expect(find_field("ncr_work_order_building_number").value).to eq(
        Ncr::BUILDING_NUMBERS[0])
      fill_in 'Vendor', with: 'New ACME'
      click_on 'Submit for approval'
      expect(current_path).to eq("/proposals/#{ncr_proposal.id}")
      expect(page).to have_content("New ACME")
      expect(page).to have_content("modified")
      # Verify it is actually saved
      work_order.reload
      expect(work_order.vendor).to eq("New ACME")
    end

    it "creates a special comment when editing" do
      visit "/ncr/work_orders/#{work_order.id}/edit"
      fill_in 'Vendor', with: "New Test Vendor"
      fill_in 'Description', with: "New Description"
      click_on 'Submit for approval'

      expect(page).to have_content("Request modified by")
      expect(page).to have_content("Description was changed to New Description")
      expect(page).to have_content("Vendor was changed to New Test Vendor")
    end

    it "has 'Discard Changes' link" do
      visit "/ncr/work_orders/#{work_order.id}/edit"
      expect(page).to have_content("Discard Changes")
      click_on "Discard Changes"
      expect(current_path).to eq("/proposals/#{work_order.proposal.id}")
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
      expect(current_path).to eq("/proposals/#{ncr_proposal.id}")
      # Verify it is actually saved
      work_order.reload
      expect(work_order.vendor).to eq("New ACME")
    end

    it "can be edited if rejected" do
      ncr_proposal.update_attributes(status: 'rejected')  # avoid workflow

      visit "/ncr/work_orders/#{work_order.id}/edit"
      expect(current_path).to eq("/ncr/work_orders/#{work_order.id}/edit")
    end

    it "can be edited if approved" do
      ncr_proposal.update_attributes(status: 'approved')  # avoid workflow

      visit "/ncr/work_orders/#{work_order.id}/edit"
      expect(current_path).to eq("/ncr/work_orders/#{work_order.id}/edit")
    end

    it "cannot be edited by someone other than the requester" do
      ncr_proposal.set_requester(FactoryGirl.create(:user))

      visit "/ncr/work_orders/#{work_order.id}/edit"
      expect(current_path).to eq("/ncr/work_orders/new")
      expect(page).to have_content('not the requester')
    end

    it "shows a edit link from a pending cart" do
      visit "/proposals/#{ncr_proposal.id}"
      expect(page).to have_content('Modify Request')
      click_on('Modify Request')
      expect(current_path).to eq("/ncr/work_orders/#{work_order.id}/edit")
    end

    it "shows a edit link from a rejected cart" do
      ncr_proposal.update_attribute(:status, 'rejected') # avoid state machine

      visit "/proposals/#{ncr_proposal.id}"
      expect(page).to have_content('Modify Request')
    end

    it "shows a edit link for an approved cart" do
      ncr_proposal.update_attribute(:status, 'approved') # avoid state machine

      visit "/proposals/#{ncr_proposal.id}"
      expect(page).to have_content('Modify Request')
    end

    it "does not show a edit link for another client" do
      ncr_proposal.client_data = nil
      ncr_proposal.save()
      visit "/proposals/#{ncr_proposal.id}"
      expect(page).not_to have_content('Modify Request')
    end

    it "does not show a edit link for non requester" do
      ncr_proposal.set_requester(FactoryGirl.create(:user))
      visit "/proposals/#{ncr_proposal.id}"
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
        select Ncr::Organization.all[0], :from => 'ncr_work_order_org_code'
      end

      it "approves emergencies" do
        choose 'BA61'
        check "This request was an emergency and I received a verbal Notice to Proceed (NTP)"
        expect {
          click_on 'Submit for approval'
        }.to change { Proposal.count }.from(0).to(1)

        proposal = Proposal.last
        expect(page).to have_content("Proposal submitted")
        expect(current_path).to eq("/proposals/#{proposal.id}")
        expect(page).to have_content("0 of 0 approved")

        expect(proposal.client_data.emergency).to eq(true)
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

        proposal = Proposal.last
        expect(page).to have_content("Proposal submitted")
        expect(current_path).to eq("/proposals/#{proposal.id}")

        expect(proposal.client_data.emergency).to eq(false)
        expect(proposal.approved?).to eq(false)
      end
    end
  end
end
