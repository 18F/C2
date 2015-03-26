describe Populator do
  describe '.create_carts_with_approvals' do
    it "creates ten carts" do
      expect {
        Populator.create_carts_with_approvals
      }.to change{ Cart.count }.from(0).to(10)
    end
  end

  describe '.random_ncr_data' do
    it "creates ten carts" do
      expect {
        Populator.random_ncr_data
      }.to change{ Ncr::WorkOrder.count }.from(0).to(50)
    end
  end
end
