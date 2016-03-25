describe "Display status text" do
  let(:create_proposal_with_parallel_approvers) { create(:proposal, :with_parallel_approvers) }
  let(:create_proposal_with_serial_approvers) { create(:proposal, :with_serial_approvers) }

  context "parallel approvals" do
    it "displays complete status" do
      proposal = create_proposal_with_parallel_approvers
      proposal.individual_steps.each { |approval| approval.complete! }

      login_as(proposal.requester)
      visit proposals_path

      expect(page).to have_content("Completed")
    end

    it "displays outstanding approvers" do
      proposal = create_proposal_with_parallel_approvers

      login_as(proposal.requester)
      visit proposals_path

      expect(page).not_to have_content("Please review")
      expect(page).to have_content("Waiting for review from:")
      proposal.approvers.each do |approver|
        expect(page).to have_content(approver.full_name)
      end
    end

    it "excludes approved approvals" do
      proposal = create_proposal_with_parallel_approvers
      first_approval = proposal.individual_steps.first
      first_approval.complete!
      first_approver = first_approval.user
      all_approvers_except_first = proposal.approvers.offset(1)

      login_as(proposal.requester)
      visit proposals_path

      expect(page).not_to have_content("Please review")
      expect(page).to have_content("Waiting for review from:")
      expect(page).not_to have_content(first_approver.full_name)
      all_approvers_except_first.each do |approver|
        expect(page).to have_content(approver.full_name)
      end
    end
  end

  context "serial approvals" do
    it "displays the first approver" do
      proposal = create_proposal_with_serial_approvers
      first_approval = proposal.individual_steps.first
      first_approver = first_approval.user
      all_approvers_except_first = proposal.approvers.offset(1)

      login_as(proposal.requester)
      visit proposals_path

      expect(page).to have_content("Waiting for review from:")
      expect(page).to have_content(first_approver.full_name)
      all_approvers_except_first.each do |approver|
        expect(page).not_to have_content(approver.full_name)
      end
    end

    it "excludes approved approvals" do
      proposal = create_proposal_with_serial_approvers
      first_approval = proposal.individual_steps.first
      first_approval.complete!
      first_approver = first_approval.user

      login_as(proposal.requester)
      visit proposals_path

      expect(page).to have_content("Waiting for review from:")
      expect(page).not_to have_content(first_approver.full_name)
    end
  end
end
