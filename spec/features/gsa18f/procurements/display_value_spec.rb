feature "the values displayed on procurements" do
  scenario "requester can see procurement details" do
    requester = create(:user, client_slug: "gsa18f")
    procurement = create(:gsa18f_procurement, :with_steps, requester: requester, urgency: 10)
    proposal = procurement.proposal

    login_as(requester)

    visit proposal_path(proposal)

    expect(page).to have_content(procurement.purchase_type)
  end

  def js_activate_modify_proposal(modify = "ul.request-actions .edit-button button")
    find(modify).trigger("click")
  end


  def js_modify_checkbox(text = "foo", selector = '#gsa18f_procurement_is_tock_billable', submit = ".request-actions .save-button button")
    find(:css, selector).set(true)
    find(submit).trigger("click")
    find('.save_confirm-modal-content .form-button[data-modal-event="confirm"]').trigger("click")
    wait_for_ajax
  end


  def create_and_visit_proposal_beta
    procurement = create(:gsa18f_procurement, :with_beta_requester)
    proposal = procurement.proposal
    login_as(proposal.requester)
    visit proposal_path(proposal)
    return proposal
  end

end
