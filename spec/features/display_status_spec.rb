describe "Display status text" do
  let(:proposal) { FactoryGirl.create(:proposal, :with_parallel_approvers) }
  before do
    # ensure unique names as we'll be testing them later
    proposal.approvers.first.update(first_name: "Uniquely", last_name: "Named")
    proposal.approvers.second.update(first_name: "Onlyof", last_name: "Itskind")
    login_as(proposal.requester)
  end

  it "displays approved status" do
    proposal.individual_approvals.each{|approval| approval.approve!}
    visit proposals_path
    expect(page).to have_content('Approved')
  end

  it "displays outstanding approvers" do
    visit proposals_path
    expect(page).not_to have_content('Please review')
    expect(page).to have_content('Waiting for review from:')
    proposal.approvers.each do |approver|
      expect(page).to have_content(approver.full_name)
    end
  end

  it "excludes approved approvals" do
    proposal.individual_approvals.first.approve!
    visit proposals_path
    expect(page).not_to have_content('Please review')
    expect(page).to have_content('Waiting for review from:')
    proposal.approvers[1..-1].each do |approver|
      expect(page).to have_content(approver.full_name)
    end
    expect(page).not_to have_content("Uniquely Named")
  end

  context "linear" do
    let(:proposal) { FactoryGirl.create(:proposal, :with_serial_approvers) }

    it "displays the first approver" do
      visit proposals_path
      expect(page).to have_content('Waiting for review from:')
      proposal.approvers[1..-1].each do |approver|
        expect(page).not_to have_content(approver.full_name)
      end
      expect(page).to have_content("Uniquely Named")
    end

    it "excludes approved approvals" do
      proposal.individual_approvals.first.approve!
      visit proposals_path
      expect(page).to have_content('Waiting for review from:')
      expect(page).not_to have_content("Uniquely Named")
    end
  end
end

