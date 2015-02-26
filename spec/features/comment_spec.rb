describe "commenting" do
  describe "on a Cart" do
    it "saves the comment" do
      cart = FactoryGirl.create(:cart_with_approvals)
      login_as(cart.requester)

      visit "/carts/#{cart.id}"
      fill_in 'comment[comment_text]', with: 'foo'
      click_on 'Send note'

      expect(current_path).to eq("/carts/#{cart.id}")
      cart.reload
      expect(cart.comments.map(&:comment_text)).to eq(['foo'])
    end
  end
end
