describe "Add attachments" do
  let(:proposal) { create(:ncr_work_order, :with_approvers).proposal }
  let!(:attachment) do
    create(:attachment, proposal: proposal,
                        user: proposal.requester)
  end

  before do
    login_as(proposal.requester)
    stub_request(:put, /.*c2-prod.s3.amazonaws.com.*/)
    stub_request(:head, /.*c2-prod.s3.amazonaws.com.*/)
    stub_request(:delete, /.*c2-prod.s3.amazonaws.com.*/)
  end

  it "is visible on a proposal" do
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

  it "saves attachments submitted via the webform" do
    proposal = create(:proposal)
    login_as(proposal.requester)

    visit proposal_path(proposal)
    page.attach_file("attachment[file]", "#{Rails.root}/app/assets/images/bg_completed_status.gif")
    click_on "Attach a File"

    expect(proposal.attachments.length).to eq 1
    expect(proposal.attachments.last.file_file_name).to eq "bg_completed_status.gif"
  end

  it "saves attachments submitted via the webform with js", :js, js_errors: false do
    dispatcher = double
    allow(dispatcher).to receive(:deliver_attachment_emails)
    allow(Dispatcher).to receive(:new).with(proposal).and_return(dispatcher)

    work_order = create(:ncr_work_order, :with_beta_requester)
    proposal = work_order.proposal
    login_as(proposal.requester)

    visit proposal_path(proposal)
    page.execute_script("$('#attachment_file').addClass('show-attachment-file');")
    page.attach_file("attachment[file]", "#{Rails.root}/app/assets/images/bg_completed_status.gif", visible: false)
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
