describe "commenting" do
  describe "on a Cart" do
    let(:cart) { FactoryGirl.create(:cart_with_approvals) }

    before do
      login_as(cart.requester)
      visit "/proposals/#{cart.proposal.id}"
    end

    it "saves the comment" do
      fill_in 'comment[comment_text]', with: 'foo'
      click_on 'Send a Comment'

      expect(current_path).to eq("/proposals/#{cart.proposal.id}")
      cart.reload
      expect(cart.comments.map(&:comment_text)).to eq(['foo'])
    end

    it "warns if the comment body is empty" do
      fill_in 'comment[comment_text]', with: ''
      click_on 'Send a Comment'

      expect(current_path).to eq("/proposals/#{cart.proposal.id}")
      expect(page).to have_content("can't be blank")
    end

    it "sends an email" do
      fill_in 'comment[comment_text]', with: 'foo'
      click_on 'Send a Comment'

      expect(email_recipients).to eq(['approver1@some-dot-gov.gov',
                                      'approver2@some-dot-gov.gov'])
    end
  end
end
