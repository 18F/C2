describe Cart do
  let(:cart) { FactoryGirl.create(:cart_with_approval_group) }
  describe '#restart' do
    it "creates new API tokens" do
      cart = FactoryGirl.create(:cart_with_approvals)
      cart.user_approvals.each(&:create_api_token!)
      expect(cart.api_tokens.length).to eq(2)

      cart.restart!

      expect(cart.api_tokens.unscoped.expired.length).to eq(2)
      expect(cart.api_tokens.unexpired.length).to eq(2)
    end
  end
end
