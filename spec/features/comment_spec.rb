feature "commenting" do
  scenario "saves the comment", :js do
    proposal = create_and_visit_proposal
    comment_text = "this is a great comment"

    js_submit_comment(comment_text)

    expect(current_path).to eq(proposal_path(proposal))
    expect(page).to have_content(comment_text)
  end

  scenario "saves the comment with javascript", js: true do
    create_and_visit_proposal_beta
    comment_text = "this is a great comment"
    js_submit_comment(comment_text, "#add_a_comment")
    wait_for_ajax
    within(".comment-list") do
      expect(page).to have_content(comment_text)
    end
  end

  scenario "redesign page hides/shows comments after 5 comments in beta view", js: true do
    work_order = create(:ncr_work_order, :with_beta_requester)
    proposal = work_order.proposal
    create(:comment, comment_text: "first comment", user: proposal.requester, proposal: proposal)
    5.times do
      create(:comment, user: proposal.requester, proposal: proposal)
    end
    login_as(proposal.requester)
    visit proposal_path(proposal)

    expect(page).to_not have_content("first comment")
    click_on("Show all activity")

    expect(page).to have_content("first comment")
    wait_for_ajax
    find(".minimize-activity").trigger("click")

    expect(page).to_not have_content("first comment")
  end

  scenario "disables attachments if none is selected", js: true do
    create_and_visit_proposal

    expect(find("#add_a_comment").disabled?).to be(true)
    fill_in "comment[comment_text]", with: "foo"
    expect(find("#add_a_comment").disabled?).to be(false)
  end

  context "when user is not yet an observer" do
    scenario "adds current user to the observers list", :js do
      proposal = create(:ncr_work_order, :with_approvers).proposal
      approver = proposal.approvers.first
      user = create(:user, client_slug: "ncr")
      approver.add_delegate(user) # so user can see proposal
      login_as(user)
      visit proposal_path(proposal)

      expect(proposal.observers).to_not include(user)
      js_submit_comment
      proposal.observers(true) # clear cache
      expect(proposal.observers).to include(user)
    end
  end

  private

  def create_and_visit_proposal
    proposal = create(:ncr_work_order, :with_approvers).proposal
    login_as(proposal.requester)
    visit proposal_path(proposal)
    proposal
  end

  def create_and_visit_proposal_beta
    work_order = create(:ncr_work_order, :with_beta_requester)
    proposal = work_order.proposal
    login_as(proposal.requester)
    visit proposal_path(proposal)
    proposal
  end

  def submit_comment(text = "foo", _submit = "Send a Comment")
    fill_in "comment_text_content", with: text
    click_on "Send"
  end

  def js_submit_comment(text = "foo", submit = "#add_a_comment")
    fill_in "comment[comment_text]", with: text
    find(submit).trigger("click")
    sleep(1)
  end
end
