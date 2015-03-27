describe 'NCR Work Orders API' do
  describe 'GET /api/v1/ncr/work_orders.json' do
    it "responds with the list of work orders" do
      proposal = FactoryGirl.create(:proposal)
      work_order = FactoryGirl.create(:ncr_work_order, proposal: proposal)

      get '/api/v1/ncr/work_orders.json'

      json = JSON.parse(response.body)
      expect(json).to eq([
        {
          'amount' => work_order.amount.to_s, # TODO should not be a string
          'building_number' => work_order.building_number,
          'code' => work_order.code,
          'emergency' => work_order.emergency,
          'expense_type' => work_order.expense_type,
          'id' => work_order.id,
          'not_to_exceed' => work_order.not_to_exceed,
          'office' => work_order.office,
          'proposal' => {
            'created_at' => proposal.created_at.iso8601(3),
            'flow' => proposal.flow,
            'id' => proposal.id,
            'status' => 'pending',
            'updated_at' => proposal.updated_at.iso8601(3)
          },
          'rwa_number' => work_order.rwa_number,
          'vendor' => work_order.vendor
        }
      ])
    end

    it "includes the requester"

    it "includes approvers"

    it "includes observers"

    it "responds with an empty list for no work orders" do
      get '/api/v1/ncr/work_orders.json'
      json = JSON.parse(response.body)
      expect(json).to eq([])
    end
  end
end
