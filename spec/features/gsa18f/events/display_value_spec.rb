feature "the values displayed on events" do
  scenario "requester can see procurement details" do
    requester = create(:user, :beta_active, client_slug: "gsa18f" )
    supervisor = create(:user, client_slug: "gsa18f", email_address: "supervisor@gsa.gov", first_name: "super")
    login_as(requester)

    visit new_gsa18f_event_path

    # expect(page).to have_content(procurement.purchase_type)
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
    # procurement = create(:gsa18f_procurement, :with_beta_requester)
    # proposal = procurement.proposal
    # login_as(proposal.requester)
    # visit proposal_path(proposal)
    # return proposal
  end

end
