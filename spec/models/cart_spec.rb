describe Cart do
  describe '#update_approval_status' do
    let(:cart) { FactoryGirl.create(:cart_with_approval_group) }
    let(:cart_id) { 1357910 }

    context "All approvals are in 'approved' status" do
      it 'updates a status based on the cart_id passed in from the params' do
        allow(cart).to receive(:all_approvals_received?).and_return(true)

        cart.update_approval_status
        expect(cart.status).to eq('approved')
      end
    end

    context "Not all approvals are in 'approved'status" do
      it 'does not update the cart status' do
        allow(cart).to receive(:all_approvals_received?).and_return(false)

        cart.update_approval_status
        expect(cart.status).to eq('pending')
      end
    end
  end

  describe '#process_approvals_without_approval_group' do
    let(:cart) { FactoryGirl.create(:cart_with_approval_group, name: 'Cart with some approvals') }
    let(:user1) { FactoryGirl.create(:user, email_address: 'user1@some-dot-gov.gov') }

    it 'excludes blank email addresses' do
      allow(User).to receive(:find_or_create_by).and_return(user1)
      params = { 'toAddress' => ["email1@some-dot-gov.gov", "email2@some-dot-gov", ""] }
      expect(User).to receive(:find_or_create_by).exactly(2).times
      cart.process_approvals_without_approval_group params
    end

  end

end
