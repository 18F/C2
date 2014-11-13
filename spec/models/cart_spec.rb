require 'spec_helper'

describe Cart do
  let(:cart) { FactoryGirl.create(:cart_with_approval_group) }

  describe '#update_approval_status' do
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

  describe '#process_approvals_from_approval_group' do
    it "copies positions from the user_roles" do
      cart.user_roles.each do |role|
        role.position += 1
        role.save!
      end

      cart.process_approvals_from_approval_group

      expect(cart.approvals.map(&:position)).to eq(cart.user_roles.map(&:position))
    end
  end

  describe '#process_approvals_without_approval_group' do
    let(:user1) { FactoryGirl.create(:user, email_address: 'user1@some-dot-gov.gov') }

    it 'excludes blank email addresses' do
      allow(User).to receive(:find_or_create_by).and_return(user1)
      params = { 'toAddress' => ["email1@some-dot-gov.gov", "email2@some-dot-gov", ""] }
      expect(User).to receive(:find_or_create_by).exactly(2).times
      cart.process_approvals_without_approval_group params
    end

  end

end
