describe Populator do
  describe '.random_ncr_data' do
    it "creates the specified number of work orders" do
      num_proposals = 5
      expect {
        Populator.random_ncr_data(num_proposals)
      }.to change{ Ncr::WorkOrder.count }.from(0).to(num_proposals)
    end
  end

  describe '.uniform_ncr_data' do
    it "creates the specified number of work orders" do
      num_proposals = 5
      expect {
        Populator.uniform_ncr_data(num_proposals)
      }.to change{ Ncr::WorkOrder.count }.from(0).to(num_proposals)
    end
  end
end
