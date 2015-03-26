describe Populator do
  describe '.create_carts_with_approvals' do
    it "creates ten carts" do
      expect {
        Populator.create_carts_with_approvals
      }.to change{ Cart.count }.from(0).to(10)
    end
  end
end
