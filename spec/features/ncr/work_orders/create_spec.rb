feature 'Creating an NCR work order' do
  around(:each) do |example|
    with_env_var('DISABLE_SANDBOX_WARNING', 'true') do
      example.run
    end
  end

  scenario 'requires sign-in' do
    visit '/ncr/work_orders/new'
    expect(current_path).to eq('/')
    expect(page).to have_content("You need to sign in")
  end

  with_feature 'RESTRICT_ACCESS' do
    scenario 'requires a GSA email address' do
      user = create(:user, email_address: 'intruder@example.com', client_slug: 'ncr')
      login_as(user)

      visit '/ncr/work_orders/new'

      expect(page.status_code).to eq(403)
      expect(page).to have_content("You must be logged in with a GSA email address")
    end
  end

  context 'when signed in as the requester' do
    let(:requester) { create(:user, client_slug: 'ncr') }
    let(:ncr_helper_class) { Class.new { extend Ncr::WorkOrdersHelper } }

    scenario 'saves a Proposal with the attributes' do
      approver = create(:user)
      login_as(requester)
      expect(Dispatcher).to receive(:deliver_new_proposal_emails)

      visit '/ncr/work_orders/new'
      fill_in 'Project title', with: "buying stuff"
      fill_in 'Description', with: "desc content"
      choose 'BA80'
      fill_in 'RWA Number', with: 'F1234567'
      fill_in 'Vendor', with: 'ACME'
      fill_in 'Amount', with: 123.45
      check "I am going to be using direct pay for this transaction"
      select approver.email_address, from: 'ncr_work_order[approving_official_email]'
      fill_in 'Building number', with: Ncr::BUILDING_NUMBERS[0]
      select Ncr::Organization.all[0], from: 'ncr_work_order_org_code'
      expect { click_on 'Submit for approval' }.to change { Proposal.count }.from(0).to(1)

      proposal = Proposal.last
      expect(proposal.public_id).to have_content("FY")
      expect(page).to have_content("Proposal submitted")
      expect(current_path).to eq("/proposals/#{proposal.id}")

      expect(proposal.name).to eq("buying stuff")
      expect(proposal.flow).to eq('linear')
      work_order = proposal.client_data
      expect(work_order.client).to eq('ncr')
      expect(work_order.expense_type).to eq('BA80')
      expect(work_order.vendor).to eq('ACME')
      expect(work_order.amount).to eq(123.45)
      expect(work_order.direct_pay).to eq(true)
      expect(work_order.building_number).to eq(Ncr::BUILDING_NUMBERS[0])
      expect(work_order.org_code).to eq(Ncr::Organization.all[0].to_s)
      expect(work_order.description).to eq('desc content')
      expect(proposal.requester).to eq(requester)
      expect(proposal.approvers.map(&:email_address)).to eq(
        [approver.email_address, Ncr::WorkOrder.ba80_budget_mailbox])
    end

    scenario 'saves a BA60 Proposal with the attributes' do
      approver = create(:user)
      login_as(requester)
      expect(Dispatcher).to receive(:deliver_new_proposal_emails)

      visit '/ncr/work_orders/new'
      fill_in 'Project title', with: "blue shells"
      fill_in 'Description', with: "desc content"
      choose 'BA60'
      fill_in 'Vendor', with: 'Yoshi'
      fill_in 'Amount', with: 123.45
      select approver.email_address, from: "Approving official's email address"
      fill_in 'Building number', with: Ncr::BUILDING_NUMBERS[0]
      select Ncr::Organization.all[0], from: 'ncr_work_order_org_code'
      expect { click_on 'Submit for approval' }.to change { Proposal.count }.from(0).to(1)

      proposal = Proposal.last
      work_order = proposal.client_data
      expect(work_order.expense_type).to eq('BA60')
      expect(proposal.approvers.map(&:email_address)).to eq [
        approver.email_address,
        Ncr::WorkOrder.ba61_tier1_budget_mailbox,
        Ncr::WorkOrder.ba61_tier2_budget_mailbox
      ]
    end

    scenario 'shows the radio button' do
      login_as(requester)
      visit '/ncr/work_orders/new'
      expect(page).to have_content('BA60')
      expect(page).to have_content('BA61')
      expect(page).to have_content('BA80')
    end

    scenario "does not show system approver emails as approver options", :js do
      expect(Ncr::WorkOrder.all_system_approver_emails.size).to eq 4
      login_as(requester)
      approving_official = create(:user)
      visit "/ncr/work_orders/new"
      within(".ncr_work_order_approving_official_email") do
        find(".selectize-control").click
        expect(page).to have_content(approving_official.email_address)
        expect(page).not_to have_content(Ncr::WorkOrder.ba61_tier1_budget_mailbox)
        expect(page).not_to have_content(Ncr::WorkOrder.ba61_tier2_budget_mailbox)
        expect(page).not_to have_content(Ncr::WorkOrder.ba80_budget_mailbox)
        expect(page).not_to have_content(Ncr::WorkOrder.ool_ba80_budget_mailbox)
      end
    end

    scenario 'shows hint text for amount field', :js do
      login_as(requester)
      visit '/ncr/work_orders/new'
      focus_field 'ncr_work_order_amount'
      expect(page).to have_content('$3,500 for supplies')
      expect(page).to have_content('$2,500 for services')
      expect(page).to have_content('$2,000 for construction')
    end

    scenario 'defaults to no approver if there was no previous request' do
      login_as(requester)
      visit '/ncr/work_orders/new'
      expect(find_field("Approving official's email address").value).to eq('')
    end

    scenario 'defaults to the approver from the last request' do
      login_as(requester)
      proposal = create(:proposal, :with_serial_approvers, requester: requester)
      visit '/ncr/work_orders/new'
      expect(find_field("Approving official's email address").value).to eq(
        proposal.approvers.first.email_address)
    end

    scenario 'requires a project_title' do
      login_as(requester)
      visit '/ncr/work_orders/new'
      expect { click_on 'Submit for approval' }.to_not change { Proposal.count }
      expect(page).to have_content("Project title can't be blank")
    end

    scenario "doesn't show the budget fields" do
      login_as(requester)
      visit '/ncr/work_orders/new'
      expect(page).to_not have_field('CL number')
      expect(page).to_not have_field('Function code')
      expect(page).to_not have_field('SOC code')
    end

    scenario "doesn't save when the amount is too high" do
      login_as(requester)
      visit '/ncr/work_orders/new'
      fill_in 'Project title', with: "buying stuff"
      choose 'BA80'
      fill_in 'Vendor', with: 'ACME'
      fill_in 'Amount', with: 10_000

      expect { click_on 'Submit for approval' }.to_not change { Proposal.count }
      expect(current_path).to eq('/ncr/work_orders')
      expect(page).to have_content("Amount must be less than or equal to $")
      expect(find_field('Amount').value).to eq('10000')
    end

    scenario "preserve form values on submission error" do
      login_as(requester)
      work_order = create(:ncr_work_order, :with_approvers)

      expect(Proposal.count).to eq(1)
      expect(ncr_helper_class.vendor_options).to eq([work_order.vendor])

      visit '/ncr/work_orders/new'
      fill_in 'Project title', with: "buying stuff"
      choose 'BA80'
      fill_in 'Vendor', with: 'ACME'
      fill_in 'Amount', with: 10_000

      expect { click_on 'Submit for approval' }.to_not change { Proposal.count }
      expect(ncr_helper_class.vendor_options('zzbar')).to eq([work_order.vendor, 'zzbar'])
      expect(find_field('Amount').value).to eq('10000')
      expect(find_field('Vendor').value).to eq('ACME')
      expect(JSON.parse(find_field('Vendor')['data-initial'])).to eq(['ACME', work_order.vendor])
    end

    scenario "includes has overwritten field names" do
      approver = create(:user)
      login_as(requester)
      visit '/ncr/work_orders/new'
      fill_in 'Project title', with: "buying stuff"
      choose 'BA80'
      fill_in 'RWA Number', with: 'B9876543'
      fill_in 'Vendor', with: 'ACME'
      fill_in 'Amount', with: 123.45
      select approver.email_address, from: 'ncr_work_order[approving_official_email]'
      fill_in 'Building number', with: Ncr::BUILDING_NUMBERS[0]
      select Ncr::Organization.all[0], from: 'ncr_work_order_org_code'
      click_on 'Submit for approval'
      expect(current_path).to eq("/proposals/#{Proposal.last.id}")
      expect(page).to have_content("RWA Number")
    end

    scenario 'hides fields based on expense', :js do
      login_as(requester)
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

    scenario 'allows attachments to be added during intake without JS' do
      login_as(requester)
      visit '/ncr/work_orders/new'
      expect(page).to have_content("Attachments")
      expect(page).not_to have_selector(".js-am-minus")
      expect(page).not_to have_selector(".js-am-plus")
      expect(page).to have_selector("input[type=file]", count: 10)
    end

    scenario 'allows attachments to be added during intake with JS', :js do
      login_as(requester)
      visit '/ncr/work_orders/new'
      expect(page).to have_content("Attachments")
      first_minus = find(".js-am-minus")
      first_plus = find(".js-am-plus")
      expect(first_minus).to be_visible
      expect(first_plus).to be_visible
      expect(first_minus).to be_disabled
      expect(find("input[type=file]")[:name]).to eq("attachments[]")
      first_plus.click # Adds one row
      expect(page).to have_selector(".js-am-minus", count: 2)
      expect(page).to have_selector(".js-am-plus", count: 2)
      expect(page).to have_selector("input[type=file]", count: 2)
    end

    scenario 'includes an initial list of buildings', :js do
      login_as(requester)
      visit '/ncr/work_orders/new'
      option = Ncr::BUILDING_NUMBERS.sample

      expect(page).not_to have_selector(".option[data-value='#{option}']")

      find("input[aria-label='Building number']").native.send_keys(option)
      expect(page).to have_selector("div.option[data-value='#{option}']")
    end

    scenario 'does not include custom buildings initially', :js do
      login_as(requester)
      visit '/ncr/work_orders/new'
      find("input[aria-label='Building number']").native.send_keys("BillDing")
      expect(page).not_to have_selector("div.option[data-value='BillDing']")
    end

    scenario 'includes previously entered buildings, too', :js do
      login_as(requester)
      create(:ncr_work_order, building_number: "BillDing")
      visit '/ncr/work_orders/new'
      find("input[aria-label='Building number']").native.send_keys("BillDing")
      expect(page).to have_selector("div.option[data-value='BillDing']")
    end

    context "selected common values on proposal page" do
      before do
        approver = create(:user)
        login_as(requester)
        visit '/ncr/work_orders/new'

        fill_in 'Project title', with: "buying stuff"
        fill_in 'Vendor', with: 'ACME'
        fill_in 'Amount', with: 123.45
        select approver.email_address, from: 'ncr_work_order[approving_official_email]'
        fill_in 'Building number', with: Ncr::BUILDING_NUMBERS[0]
        select Ncr::Organization.all[0], from: 'ncr_work_order_org_code'
      end

      scenario 'approves emergencies' do
        choose 'BA61'
        check "This request was an emergency and I received a verbal Notice to Proceed (NTP)"
        expect { click_on 'Submit for approval' }.to change { Proposal.count }.from(0).to(1)

        proposal = Proposal.last
        expect(page).to have_content("Proposal submitted")
        expect(current_path).to eq("/proposals/#{proposal.id}")
        expect(page).to have_content("0 of 0 approved")

        expect(proposal.client_data.emergency).to eq(true)
        expect(proposal.approved?).to eq(true)
        expect(proposal.approvers).to be_empty
        expect(proposal.client_data.decorate.current_approver_email_address).to eq(Ncr::WorkOrderDecorator::EMERGENCY_APPROVER_EMAIL)
        expect(proposal.client_data.decorate.final_approver_email_address).to eq(Ncr::WorkOrderDecorator::EMERGENCY_APPROVER_EMAIL)
      end

      scenario 'does not set emergencies if form type changes' do
        choose 'BA61'
        check 'This request was an emergency and I received a verbal Notice to Proceed (NTP)'
        choose 'BA80'
        fill_in 'RWA Number', with: 'R9876543'
        expect { click_on 'Submit for approval' }.to change { Proposal.count }.from(0).to(1)

        proposal = Proposal.last
        expect(page).to have_content('Proposal submitted')
        expect(current_path).to eq("/proposals/#{proposal.id}")

        expect(proposal.client_data.emergency).to eq(false)
        expect(proposal.approved?).to eq(false)
      end
    end

    scenario 'does not disable the emergency field' do
      login_as(requester)
      visit '/ncr/work_orders/new'
      expect(find_field('emergency')).not_to be_disabled
    end
  end

  def focus_field(field_id)
    execute_script "document.getElementById('#{field_id}').scrollIntoView()"
    execute_script "$('##{field_id}').focus()"
  end
end
