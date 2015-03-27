describe 'NCR Work Orders API' do
  describe 'GET /api/v1/ncr/work_orders.json' do
    it "responds with the list of work orders" do
      work_order = FactoryGirl.create(:ncr_work_order)

      get '/api/v1/ncr/work_orders.json'

      json = JSON.parse(response.body).map(&:symbolize_keys!)
      expect(json).to eq([
        {
          amount: work_order.amount.to_s, # TODO should not be a string
          building_number: work_order.building_number,
          code: work_order.code,
          emergency: work_order.emergency,
          expense_type: work_order.expense_type,
          id: work_order.id,
          not_to_exceed: work_order.not_to_exceed,
          office: work_order.office,
          rwa_number: work_order.rwa_number,
          vendor: work_order.vendor
        }
      ])
    end

    it "responds with an empty list for no work orders" do
      get '/api/v1/ncr/work_orders.json'
      json = JSON.parse(response.body)
      expect(json).to eq([])
    end
  end
end
