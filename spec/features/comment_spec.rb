describe "commenting" do
  let(:proposal) { FactoryGirl.create(:proposal, :with_parallel_approvers) }

  before do
    login_as(proposal.requester)
    visit "/proposals/#{proposal.id}"
  end

  it "saves the comment" do
    fill_in 'comment[comment_text]', with: 'foo'
    click_on 'Send a Comment'

    expect(current_path).to eq("/proposals/#{proposal.id}")
    proposal.reload
    expect(proposal.comments.map(&:comment_text)).to eq(['foo'])
  end

  it "warns if the comment body is empty" do
    fill_in 'comment[comment_text]', with: ''
    click_on 'Send a Comment'

    expect(current_path).to eq("/proposals/#{proposal.id}")
    expect(page).to have_content("can't be blank")
  end

  it "disables attachments if none is selected", js: true do
    visit proposal_path(proposal)
    expect(find("#add_a_comment").disabled?).to be(true)
    fill_in 'comment[comment_text]', with: 'foo'
    expect(find("#add_a_comment").disabled?).to be(false)
  end

  it "sends an email" do
    fill_in 'comment[comment_text]', with: 'foo'
    click_on 'Send a Comment'

    expect(email_recipients).to eq([
      proposal.approvers.first.email_address,
      proposal.approvers.second.email_address
    ].sort)
  end
end
