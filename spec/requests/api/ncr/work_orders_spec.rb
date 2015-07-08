describe 'NCR Work Orders API' do
  # TODO share common functionality w/ other API specs

  describe 'GET /api/v1/ncr/work_orders.json' do
    without_feature 'API_ENABLED' do
      it "gives a 403" do
        json = get_json('/api/v1/ncr/work_orders.json')
        expect(response.status).to eq(403)
        expect(json['message']).to eq("Not authorized")
      end
    end

    with_feature 'API_ENABLED' do
      it "responds with the list of work orders" do
        work_order = FactoryGirl.create(:ncr_work_order)
        proposal = work_order.proposal

        json = get_json('/api/v1/ncr/work_orders.json')

        expect(response.status).to eq(200)
        expect(json).to eq([
          {
            'amount' => work_order.amount.to_s,
            'building_number' => work_order.building_number,
            'code' => work_order.code,
            'description' => work_order.description,
            'emergency' => work_order.emergency,
            'expense_type' => work_order.expense_type,
            'id' => work_order.id,
            'name' => work_order.name,
            'not_to_exceed' => work_order.not_to_exceed,
            'org_code' => work_order.org_code,
            'proposal' => {
              'approvals' => [],
              'created_at' => time_to_json(proposal.created_at),
              'flow' => proposal.flow,
              'id' => proposal.id,
              'requester' => {
                'created_at' => time_to_json(proposal.requester.created_at),
                'id' => proposal.requester_id,
                'updated_at' => time_to_json(proposal.requester.updated_at)
              },
              'status' => 'pending',
              'updated_at' => time_to_json(proposal.updated_at)
            },
            'rwa_number' => work_order.rwa_number,
            'vendor' => work_order.vendor
          }
        ])
      end

      it "displays the name from the proposal" do
        work_order = FactoryGirl.create(:ncr_work_order)
        json = get_json('/api/v1/ncr/work_orders.json')
        expect(json[0]['name']).to eq(work_order.name)
      end

      it "returns the newest first" do
        Timecop.freeze do
          # create WorkOrders one minute apart
          2.times do |i|
            Timecop.freeze(i.minutes.ago) do
              FactoryGirl.create(:ncr_work_order)
            end
          end
        end

        json = get_json('/api/v1/ncr/work_orders.json')

        times = json.map {|order| DateTime.parse(order['proposal']['created_at']) }
        expect(times[1]).to eq(times[0] - 1.minute)
      end

      it "includes the requester" do
        work_order = FactoryGirl.create(:ncr_work_order)
        requester = work_order.proposal.requester

        json = get_json('/api/v1/ncr/work_orders.json')

        expect(json[0]['proposal']['requester']).to eq(
          'created_at' => time_to_json(requester.created_at),
          'id' => requester.id,
          'updated_at' => time_to_json(requester.updated_at)
        )
      end

      it "includes approvers" do
        work_order = FactoryGirl.create(:ncr_work_order, :with_approvers)

        json = get_json('/api/v1/ncr/work_orders.json')

        proposal = work_order.proposal
        approvals = proposal.approvals
        expect(approvals.size).to eq(2)

        approval = proposal.approvals[0]
        approver = approval.user

        expect(json[0]['proposal']['approvals'][0]).to eq(
          'id' => approval.id,
          'status' => 'actionable',
          'user' => {
            'created_at' => time_to_json(approver.created_at),
            'id' => approver.id,
            'updated_at' => time_to_json(approver.updated_at)
          }
        )
      end

      it "includes observers"

      it "responds with an empty list for no work orders" do
        json = get_json('/api/v1/ncr/work_orders.json')
        expect(json).to eq([])
      end

      it "can be `limit`ed" do
        3.times do
          FactoryGirl.create(:ncr_work_order, :with_approvers)
        end

        json = get_json('/api/v1/ncr/work_orders.json?limit=2')

        expect(json.size).to eq(2)
      end

      it "can be `offset`" do
        work_orders = 3.times.map do
          FactoryGirl.create(:ncr_work_order, :with_approvers)
        end

        json = get_json('/api/v1/ncr/work_orders.json?offset=1')

        ids = json.map {|order| order['id'] }
        expect(ids).to eq(work_orders.map(&:id).reverse[1..-1])
      end

      it "matches the format in the API documentation"

      describe "CORS" do
        let(:origin) { 'http://corsexample.com/' }
        let(:headers) {
          {
            'HTTP_ORIGIN' => origin,
            'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'GET'
          }
        }

        it "sets the Access-Control-Allow-Origin header to allow requests from anywhere" do
          get '/api/v1/ncr/work_orders.json', {}, headers
          expect(response.headers['Access-Control-Allow-Origin']).to eq(origin)
        end

        it "allows general HTTP methods (GET/POST/PUT)" do
          get '/api/v1/ncr/work_orders.json', {}, headers

          allowed_http_methods = response.header['Access-Control-Allow-Methods']
          %w{GET POST PUT}.each do |method|
            expect(allowed_http_methods).to include(method)
          end
        end

        it "supports OPTIONS requests" do
          options '/api/v1/ncr/work_orders.json', {}, headers
          expect(response.status).to eq(200)
          expect(response.body).to eq('')
        end
      end
    end
  end
end
