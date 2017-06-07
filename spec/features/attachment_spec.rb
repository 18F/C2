describe "Add attachments" do
  let(:proposal) { create(:ncr_work_order, :with_approvers).proposal }
  let!(:attachment) do
    create(:attachment, proposal: proposal,
                        user: proposal.requester)
  end

  before do
    stub_request(:put, /.*c2-prod.s3.amazonaws.com.*/)
    stub_request(:head, /.*c2-prod.s3.amazonaws.com.*/)
    stub_request(:delete, /.*c2-prod.s3.amazonaws.com.*/)
  end

  it "is visible on a proposal" do
    login_as(proposal.requester)
    visit proposal_path(proposal)
    expect(page).to have_content(attachment.file_file_name)
  end

  it "disables 'add attachment' button if no attachment is selected", :js do
    
    login_as(proposal.requester)

    visit proposal_path(proposal)
    execute_script("$('#add_a_file[disabled]').show()")
    expect(page).to have_selector("#add_a_file[disabled]")
  end

  it "does not have a delete link for another" do
    login_as(proposal.approvers.first)
    visit proposal_path(proposal)
    expect(page).not_to have_button("Delete")
  end

  it "saves attachments submitted via the webform with js", :js, js_errors: false do
    new_proposal = create_new_proposal
    dispatcher = double
    allow(dispatcher).to receive(:deliver_attachment_emails)
    allow(Dispatcher).to receive(:new).with(new_proposal).and_return(dispatcher)

    login_as(new_proposal.requester)

    visit proposal_path(new_proposal)

    page.execute_script("$('#attachment_file').addClass('show-attachment-file');")
    page.attach_file("attachment[file]", "#{Rails.root}/app/assets/images/bg_completed_status.gif", visible: false)
    page.save_screenshot('../screen.png', full: true)
    wait_for_ajax
    
    within(".attachment-list") do
      expect(page).to have_content("bg_completed_status.gif")
    end
    within("#card-for-activity") do
      expect(page).to have_content("bg_completed_status.gif")
    end
    expect(dispatcher).to have_received(:deliver_attachment_emails)
  end

  it "deletes attachments with js", :js do
    work_order = create(:ncr_work_order, :with_beta_requester)
    proposal = work_order.proposal
    create(:attachment, proposal: proposal,
                        user: proposal.requester)
    login_as(proposal.requester)
    visit proposal_path(proposal)
    page.find('.attachment-list-item').find('.remove-button').click
    click_on "REMOVE"
    wait_for_ajax
    expect(page).to have_content("Attachment removed")
  end

  # it "emails everyone involved in the proposal" do
  #   dispatcher = double
  #   allow(dispatcher).to receive(:deliver_attachment_emails)
  #   allow(Dispatcher).to receive(:new).with(proposal).and_return(dispatcher)
  #   proposal.add_observer(create(:user, client_slug: "ncr"))

  #   visit proposal_path(proposal)
  #   page.attach_file("attachment[file]", "#{Rails.root}/app/assets/images/bg_completed_status.gif")
  #   click_on "Attach a File"

  #   expect(dispatcher).to have_received(:deliver_attachment_emails)
  # end
end

def show_attachment_buttons
    execute_script("$('input[type=file]').show()")
end

def create_new_proposal
  approver = create(:user, client_slug: "ncr", email_address: 'approver123@test.com')
  organization = create(:ncr_organization)
  project_title = "buying stuff"
  requester = create(:user, client_slug: "ncr", email_address: 'requester123@test.com')

  login_as(requester)

  visit new_ncr_work_order_path
  fill_in 'Project title', with: project_title
  fill_in 'Description', with: "desc content"
  choose 'BA80'
  fill_in 'RWA#', with: 'F1234567'
  fill_in_selectized("ncr_work_order_building_number", "Test building")
  fill_in_selectized("ncr_work_order_vendor", "ACME")
  fill_in 'Amount', with: 123.45
  fill_in_selectized("ncr_work_order_approving_official", approver.email_address)
  fill_in_selectized("ncr_work_order_ncr_organization", organization.code_and_name)
  click_on "SUBMIT"
  sleep(1)
  Proposal.last
end
