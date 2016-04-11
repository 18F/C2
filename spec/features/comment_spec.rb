describe "commenting" do
  it "saves the comment" do
    proposal = create_and_visit_proposal
    comment_text = "this is a great comment"

    submit_comment(comment_text)

    expect(current_path).to eq(proposal_path(proposal))
    expect(page).to have_content(comment_text)
    expect(page).to have_content("You successfully added a comment")
  end

  it "disables attachments if none is selected", js: true do
    create_and_visit_proposal

    expect(find("#add_a_comment").disabled?).to be(true)
    fill_in "comment[comment_text]", with: "foo"
    expect(find("#add_a_comment").disabled?).to be(false)
  end

  describe "when user is not yet an observer" do
    it "adds current user to the observers list" do
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

  def submit_comment(text = "foo")
    fill_in "comment[comment_text]", with: text
    click_on "Send a Comment"
  end
end
