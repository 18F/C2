feature "commenting" do
  scenario "saves the comment" do
    proposal = create_and_visit_proposal
    comment_text = "this is a great comment"

    submit_comment(comment_text)

    expect(current_path).to eq(proposal_path(proposal))
    expect(page).to have_content(comment_text)
    expect(page).to have_content("You successfully added a comment")
  end

  scenario "saves the comment with javascript", js: true do
    proposal = create_and_visit_proposal
    visit "/proposals/#{proposal.id}?detail=new" 
    comment_text = "this is a great comment"
    js_submit_comment(comment_text, "#add_a_comment")
    wait_for_ajax
    within(".comment-list") do 
      expect(page).to have_content(comment_text)
    end
    visit "/proposals/#{proposal.id}?detail=old"
  end

  scenario "Send button is disabled after submitting with javascript", js: true do
    proposal = create_and_visit_proposal
    visit "/proposals/#{proposal.id}?detail=new" 
    comment_text = "this is a great comment"
    js_submit_comment(comment_text, "#add_a_comment")
    wait_for_ajax
    expect(find("#add_a_comment").disabled?).to be(true)
    visit "/proposals/#{proposal.id}?detail=old"
  end

  scenario "disables attachments if none is selected", js: true do
    create_and_visit_proposal

    expect(find("#add_a_comment").disabled?).to be(true)
    fill_in "comment[comment_text]", with: "foo"
    expect(find("#add_a_comment").disabled?).to be(false)
  end

  context "when user is not yet an observer" do
    scenario "adds current user to the observers list" do
      proposal = create(:proposal, :with_parallel_approvers)
      approver = proposal.approvers.first
      user = create(:user)
      approver.add_delegate(user) # so user can see proposal
      login_as(user)
      visit proposal_path(proposal)

      expect(proposal.observers).to_not include(user)
      submit_comment
      proposal.observers(true) # clear cache
      expect(proposal.observers).to include(user)
    end
  end

  private

  def create_and_visit_proposal
    proposal = create(:proposal, :with_parallel_approvers)
    login_as(proposal.requester)
    visit proposal_path(proposal)
    proposal
  end

  def submit_comment(text = "foo", submit = "Send a Comment")
    fill_in "comment[comment_text]", with: text
    click_on "Send a Comment"
  end

  def js_submit_comment(text = "foo", submit = "#add_a_comment")
    fill_in "comment[comment_text]", with: text
    find(submit).trigger("click")
  end

end
