describe "Modify Proposal Spec" do
  scenario "update existing title field on proposal successfully", js: true do
    proposal = create_and_visit_proposal_beta
    title_selector = 'ncr_work_order_project_title'
    new_title_text = "New title text"
    expect(page).to have_selector('#' + title_selector, visible: false)
    js_activate_modify_proposal
    expect(page).to have_selector('#' + title_selector, visible: true)
    js_modify_proposal(new_title_text, title_selector)
    within("#proposal-title-wrapper") do
      within(".detail-value") do
        expect(page).to have_content(new_title_text)
      end
    end
  end

  scenario "submit content in form, then cancel submission", js: true do
    proposal = create_and_visit_proposal_beta
    title_selector = 'ncr_work_order_project_title'
    new_title_text = "New title text"
    expect(page).to have_selector('#' + title_selector, visible: false)
    js_activate_modify_proposal
    expect(page).to have_selector('#' + title_selector, visible: true)
    js_cancel_before_modify_proposal(new_title_text, title_selector)
    within("#proposal-title-wrapper") do
      within(".detail-value") do
        expect(page).not_to have_content(new_title_text)
      end
    end
  end

  private

  def js_activate_modify_proposal(modify = "ul.request-actions .edit-button button")
    find(modify).trigger("click")
  end


  def js_modify_proposal(text = "foo", selector = 'ncr_work_order[project_title]', submit = ".request-actions .save-button button")
    fill_in(selector, with: text)
    find(submit).trigger("click")
    find('.save_confirm-modal-content .form-button[data-modal-event="confirm"]').trigger("click")
    wait_for_ajax
  end

  def js_cancel_before_modify_proposal(text = "foo", selector = 'ncr_work_order[project_title]', submit = ".request-actions .save-button button")
    fill_in('ncr_work_order_project_title', with: text)
    find(submit).trigger("click")
    find('.save_confirm-modal-content .form-button[data-modal-event="cancel"]').trigger("click")
    find(".request-actions .cancel-button button").trigger("click")
  end

  def create_and_visit_proposal_beta
    work_order = create(:ncr_work_order, :with_beta_requester)
    proposal = work_order.proposal
    login_as(proposal.requester)
    visit proposal_path(proposal)
  end
end
