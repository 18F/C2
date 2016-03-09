describe ClientDataCollectionDecorator do
  describe "#results" do
    it "returns query path, month, year, count, and cost for relation" do
      Timecop.freeze(Time.local(2016, 12, 30)) do
        client_data_object = {
          "year" => "2016",
          "month" => "12",
          "count" => "123",
          "cost" => "456"
        }

        results = ClientDataCollectionDecorator.new([client_data_object]).results

        expect(results).to eq([{
          path: "/proposals/query?end_date=2017-01-01&start_date=2016-12-01",
          month: "Dec",
          year: 2016,
          count: 123,
          cost: 456.0
        }])
      end
    end
  end
end
