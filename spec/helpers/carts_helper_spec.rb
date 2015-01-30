describe CartsHelper do
  describe '#display_status' do
    it "displays approved status" do
      cart = FactoryGirl.create(:cart, status: 'approved')
      expect(helper.display_status(cart)).to eq('Approved')
    end

    it "displays rejected status" do
      cart = FactoryGirl.create(:cart, status: 'rejected')
      expect(helper.display_status(cart)).to eq('Rejected')
    end

    it "displays outstanding approvers" do
      cart = FactoryGirl.create(:cart_with_approvals)
      cart.approvals.first.update_attribute(:status, 'approved')

      expect(helper.display_status(cart)).to eq("Waiting for approval from: Liono Approver2")
    end
  end
end
