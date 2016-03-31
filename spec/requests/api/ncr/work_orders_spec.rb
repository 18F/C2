describe 'NCR Work Orders API' do
  include EnvVarSpecHelper

  describe 'GET /api/v1/ncr/work_orders.json' do
    it "gives a 403" do
      with_env_var("API_ENABLED", "false") do
        json = get_json('/api/v1/ncr/work_orders.json')
        expect(response.status).to eq(403)
        expect(json['message']).to eq("Not authorized")
      end
    end

    it "responds with the list of work orders" do
      with_env_var("API_ENABLED", "true") do
        work_order = create(:ncr_work_order, :with_observers)
        proposal = work_order.proposal
        observers = proposal.observers.map do |user|
          {
            "created_at" => time_to_json(user.created_at),
            "id"=> user.id,
            "updated_at"=> time_to_json(user.updated_at)
          }
        end
        json = get_json("/api/v1/ncr/work_orders.json")

        expect(response.status).to eq(200)
        expect(json).to eq([
          {
            "amount" => work_order.amount.to_s,
            "building_number" => work_order.building_number,
            "description" => work_order.description,
            "emergency" => work_order.emergency,
            "expense_type" => work_order.expense_type,
            "id" => work_order.id,
            "name" => work_order.name,
            "not_to_exceed" => work_order.not_to_exceed,
            "observers" => observers,
            "organization_code_and_name" => work_order.organization_code_and_name,
            "proposal" => {
              "created_at" => time_to_json(proposal.created_at),
              "id" => proposal.id,
              "status" => "pending",
              "updated_at" => time_to_json(proposal.updated_at),
              "requester" => {
                "created_at" => time_to_json(proposal.requester.created_at),
                "id" => proposal.requester_id,
                "updated_at" => time_to_json(proposal.requester.updated_at)
              },
              "steps" => []
            },
            "rwa_number" => work_order.rwa_number,
            "vendor" => work_order.vendor,
            "work_order_code" => work_order.work_order_code
          }
        ])
      end
    end

    it "displays the name from the proposal" do
      with_env_var("API_ENABLED", "true") do
        work_order = create(:ncr_work_order)
        json = get_json('/api/v1/ncr/work_orders.json')
        expect(json[0]['name']).to eq(work_order.name)
      end
    end

    it "returns the newest first" do
      with_env_var("API_ENABLED", "true") do
        Timecop.freeze do
          # create WorkOrders one minute apart
          2.times do |i|
            Timecop.freeze(i.minutes.ago) do
              create(:ncr_work_order)
            end
          end
        end

        json = get_json('/api/v1/ncr/work_orders.json')

        times = json.map {|order| DateTime.parse(order['proposal']['created_at']) }
        expect(times[1]).to eq(times[0] - 1.minute)
      end
    end

    it "includes the requester" do
      with_env_var("API_ENABLED", "true") do
        work_order = create(:ncr_work_order)
        requester = work_order.proposal.requester

        json = get_json('/api/v1/ncr/work_orders.json')

        expect(json[0]['proposal']['requester']).to eq(
          'created_at' => time_to_json(requester.created_at),
          'id' => requester.id,
          'updated_at' => time_to_json(requester.updated_at)
        )
      end
    end

    it "includes approvers" do
      with_env_var("API_ENABLED", "true") do
        work_order = create(:ncr_work_order, :with_approvers)

        json = get_json('/api/v1/ncr/work_orders.json')

        proposal = work_order.proposal
        approvals = proposal.individual_steps
        expect(approvals.size).to eq(2)

        approval = proposal.individual_steps.first
        approver = approval.user

        expect(json[0]["proposal"]["steps"][0]).to eq(
          "id" => approval.id,
          "status" => "actionable",
          "user" => {
            "created_at" => time_to_json(approver.created_at),
            "id" => approver.id,
            "updated_at" => time_to_json(approver.updated_at)
          }
        )
      end
    end

    it "responds with an empty list for no work orders" do
      with_env_var("API_ENABLED", "true") do
        json = get_json("/api/v1/ncr/work_orders.json")
        expect(json).to eq([])
      end
    end

    it "can be `limit`ed" do
      create_list(:ncr_work_order, 3, :with_approvers)

      json = get_json('/api/v1/ncr/work_orders.json?limit=2')

      expect(json.size).to eq(2)
    end

    it "can be `offset`" do
      with_env_var("API_ENABLED", "true") do
        work_orders = create_list(:ncr_work_order, 3, :with_approvers)

        json = get_json('/api/v1/ncr/work_orders.json?offset=1')
        ids = json.map {|order| order['id'] }

        expect(ids).to eq(work_orders.map(&:id).reverse[1..-1])
      end
    end

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
