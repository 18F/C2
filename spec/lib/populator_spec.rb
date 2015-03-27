describe Populator do
  describe '.create_carts_with_approvals' do
    it "creates ten carts" do
      expect {
        Populator.create_carts_with_approvals
      }.to change{ Cart.count }.from(0).to(10)
    end
  end

  describe '.random_ncr_data' do
    it "creates the specified number of work orders" do
      num_proposals = 5
      expect {
        Populator.random_ncr_data(num_proposals)
      }.to change{ Ncr::WorkOrder.count }.from(0).to(num_proposals)
    end
  end
end
