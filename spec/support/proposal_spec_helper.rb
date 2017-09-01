module ProposalSpecHelper
  def linear_approval_statuses(proposal)
    proposal.individual_steps.pluck(:status)
  end

  def fully_complete(proposal, completer = nil)
    proposal.individual_steps.each do |step|
      step.reload
      step.complete!
      step.update(completer: completer) if completer
    end
  end

  def visit_ncr_request_with_approver
    approver = create(:user, client_slug: "ncr")
    organization = create(:ncr_organization)
    project_title = "buying stuff"
    requester = create(:user, client_slug: "ncr")

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

    proposal = requester.proposals.last

    visit proposal_path(proposal)

    proposal
  end
end
