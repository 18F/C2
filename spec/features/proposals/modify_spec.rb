describe "Modify Proposal Spec" do
  scenario "update existing proposal successfully", js: true do
    proposal = create_and_visit_proposal_beta
    title_selector = "#ncr_work_order_project_title"
    new_title_text = "New title text"
    expect(page).to have_selector(title_selector, visible: false)
    js_activate_modify_proposal
    expect(page).to have_selector(title_selector, visible: true)
    js_modify_proposal(new_title_text, title_selector)
    expect(page).find(".proposal-title-wrapper .detail-value") have_content(new_title_text)
  end

  private

  def js_activate_modify_proposal(modify = "ul.request-actions .edit-button button")
    find(modify).trigger("click")
  end


  def js_modify_proposal(text = "foo", selector = "#ncr_work_order_project_title", submit = ".request-actions .save-button button")
    fill_in selector, with: text
    find(submit).trigger("click")
    find(".save_confirm-modal-content .form-button").trigger("click")
    wait_for_ajax
  end

  def create_and_visit_proposal_beta
    work_order = create(:ncr_work_order, :with_beta_requester)
    proposal = work_order.proposal
    login_as(proposal.requester)
    visit proposal_path(proposal)
    expect(current_path).to eq(proposal_path(proposal))
    proposal
  end
end
