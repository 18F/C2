describe "commenting" do
  let(:proposal) { create(:proposal, :with_parallel_approvers) }
  let(:user)     { proposal.requester }

  before do
    login_as(user)
    visit "/proposals/#{proposal.id}"
  end

  it "saves the comment" do
    submit_comment
    expect(current_path).to eq("/proposals/#{proposal.id}")
    proposal.reload
    expect(proposal.comments.map(&:comment_text)).to eq(['foo'])
  end

  it "warns if the comment body is empty" do
    submit_comment("")
    expect(current_path).to eq("/proposals/#{proposal.id}")
    expect(page).to have_content("can't be blank")
  end

  it "disables attachments if none is selected", js: true do
    expect(find("#add_a_comment").disabled?).to be(true)
    fill_in "comment[comment_text]", with: "foo"
    expect(find("#add_a_comment").disabled?).to be(false)
  end

  it "sends an email" do
    submit_comment
    expect(email_recipients).to eq([
      proposal.approvers.first.email_address,
      proposal.approvers.second.email_address
    ].sort)
  end

  describe "when user is not yet an observer" do
    let(:approver) { proposal.approvers.first }
    let(:user)     { create(:user) }
    before do
      approver.add_delegate(user) # so user can see proposal
      login_as(user)
      visit "/proposals/#{proposal.id}"
    end

    it "adds current user to the observers list" do
      expect(proposal.observers).to_not include(user)
      submit_comment
      proposal.observers(true) # clear cache
      expect(proposal.observers).to include(user)
    end
  end
end

def submit_comment(text = "foo")
  fill_in "comment[comment_text]", with: text
  click_on "Send a Comment"
end
