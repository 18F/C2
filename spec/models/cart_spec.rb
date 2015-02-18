describe Cart do
  let(:cart) { FactoryGirl.create(:cart_with_approval_group) }

  describe '#update_approval_status' do
    context "All approvals are in 'approved' status" do
      it 'updates a status based on the cart_id passed in from the params' do
        expect(cart).to receive(:all_approvals_received?).and_return(true)

        cart.update_approval_status
        expect(cart.status).to eq('approved')
      end
    end

    context "Not all approvals are in 'approved'status" do
      it 'does not update the cart status' do
        expect(cart).to receive(:all_approvals_received?).and_return(false)

        cart.update_approval_status
        expect(cart.status).to eq('pending')
      end
    end
  end

  describe '#default value should be correct' do
    it 'sets status to pending by default' do
      expect(cart.status).to eq('pending')
    end
  end

  describe '#process_approvals_from_approval_group' do
    it "copies positions from the user_roles" do
      cart.user_roles.each do |role|
        role.position += 1
        role.save!
      end

      cart.process_approvals_from_approval_group
      expect(cart.approvals.order('user_id ASC').map(&:position)).to eq(cart.user_roles.order('user_id ASC').map(&:position))
    end
  end

  describe '#process_approvals_without_approval_group' do
    let(:user1) { FactoryGirl.create(:user, email_address: 'user1@some-dot-gov.gov') }

    it 'excludes blank email addresses' do
      expect(User).to receive(:find_or_create_by).and_return(user1).exactly(2).times
      params = { 'toAddress' => ["email1@some-dot-gov.gov", "email2@some-dot-gov", ""] }
      cart.process_approvals_without_approval_group params
    end
  end

  describe '#find_cart_without_name' do
    let(:cart) { FactoryGirl.create(:cart_with_approval_group, name: '30003') }
    let(:cart_id) { 1357910 }
    let(:cart_name) {'30003'}
    it 'finds cart' do
      c = Cart.existing_or_new_cart({'cartNumber' => 30003})
      expect(c.name).to eq('30003');
    end
  end

  describe '#ordered_awaiting_approvals' do
    let(:cart) { FactoryGirl.create(:cart_with_approvals) }

    it "returns users in order of position" do
      cart.approvals.first.update_attribute(:position, 5)
      expect(cart.ordered_awaiting_approvals).to eq(cart.awaiting_approvals.order('id DESC'))
    end
  end

  describe '#currently_awaiting_approvers' do
    it "gives a consistently ordered list when in parallel" do
      cart = FactoryGirl.create(:cart_with_approvals)
      last_names = cart.currently_awaiting_approvers.map(&:last_name)
      expect(last_names).to eq(['Approver1', 'Approver2'])

      cart.approvals.first.update_attribute(:position, 5)
      last_names = cart.currently_awaiting_approvers.map(&:last_name)
      expect(last_names).to eq(['Approver2', 'Approver1'])
    end
    it "gives only the first approver when linear" do
      cart = FactoryGirl.create(:cart_with_approvals, flow: 'linear')
      last_names = cart.currently_awaiting_approvers.map(&:last_name)
      expect(last_names).to eq(['Approver1'])

      cart.approvals.first.update_attribute(:position, 5)
      last_names = cart.currently_awaiting_approvers.map(&:last_name)
      expect(last_names).to eq(['Approver2'])
    end
  end

  context 'scopes' do
    let(:approved_cart1) { FactoryGirl.create(:cart, status: 'approved') }
    let(:approved_cart2) { FactoryGirl.create(:cart, status: 'approved') }
    let(:pending_cart)  { FactoryGirl.create(:cart, status: 'pending') }
    let(:rejected_cart)   { FactoryGirl.create(:cart, status: 'rejected') }

    describe 'approved' do
      it "returns approved carts" do
        approved_cart1
        approved_cart2
        pending_cart
        expect(Cart.approved).to eq [approved_cart1, approved_cart2]
      end
    end

    describe 'open' do
      it 'returns open carts' do
        approved_cart1
        pending_cart
        expect(Cart.open).to eq [pending_cart]
      end
    end

    describe 'closed' do
      it 'returns closed carts' do
        approved_cart1
        pending_cart
        rejected_cart
        expect(Cart.closed).to eq [approved_cart1, rejected_cart]
      end
    end

  end

end
