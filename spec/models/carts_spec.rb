require 'spec_helper'

describe Cart do
  describe '#update_status_for_cart' do
    let(:cart) { FactoryGirl.create(:cart) }
    let(:cart_with_approvals) { FactoryGirl.create(:cart_with_multiple_approvals) }
    let(:cart_id) { 1357910 }

    context "All approvals are in 'approved' status" do
      it 'updates a status based on the cart_id passed in from the params' do
        Cart.stub(:find_by_id).and_return(cart_with_approvals)
        cart_with_approvals.stub(:has_all_approvals?).and_return(true)

        Cart.update_status_for_cart(cart_id)
        expect(cart_with_approvals.status).to eq('approved')
      end
    end

    context "Not all approvals are in 'approved'status" do
      it 'does not update the cart status' do
        Cart.stub(:find_by_id).and_return(cart_with_approvals)
        cart_with_approvals.stub(:has_all_approvals?).and_return(false)

        Cart.update_status_for_cart(cart_id)
        expect(cart_with_approvals.status).to eq('pending')
      end
    end
  end
end
