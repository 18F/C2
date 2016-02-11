describe TabularData::Container do
  describe "#initialize" do
    it "sets the columns" do
      config = {
        engine: "Proposal",
        column_configs: { a: true, b: true, c: true },
        columns: ["a", "b", "c"]
      }

      container = TabularData::Container.new(:a_name, config)

      expect(container.columns.length).to eq(3)
      expect(container.columns.map(&:name)).to eq(["a", "b", "c"])
    end

    it "does not modify the query if there are no joins" do
      container = TabularData::Container.new(:a_name, engine: "Proposal")

      expect(container.rows.to_sql).to eq(Proposal.all.to_sql)
    end

    it "aliases direct joins" do
      container = TabularData::Container.new(:a_name, engine: "Proposal", joins: { requester: true })

      expect(container.rows.to_sql).to include('ON "requester"."id" = "proposals"."requester_id"')
    end

    it "aliases indirect joins" do
      container = TabularData::Container.new(:a_name, engine: "ApiToken", joins: { step: true, user: true })

      expect(container.rows.to_sql).to include('ON "user"."id" = "steps"."user_id"')
    end

    it "sets sort" do
      config = {
        engine: "Proposal",
        column_configs: { a: true, b: true },
        columns: ["a", "b"],
        sort: "-a"
      }

      container = TabularData::Container.new(:a_name, config)

      expect(container.rows.to_sql).to include("ORDER BY (proposals.a) DESC")
      expect(container.frozen_sort).to be(false)
      expect(container.columns[0].sort_dir).to be(:desc)
      expect(container.columns[1].sort_dir).to be_nil
    end

    it "allows the sort to be frozen" do
      config = {
        engine: "Proposal",
        column_configs: { a: true, b: true },
        columns: ["a", "b"],
        sort: "-a",
        frozen_sort: true
      }

      container = TabularData::Container.new(:a_name, config)

      expect(container.rows.to_sql).not_to include("ORDER BY (proposals.a) DESC")
      expect(container.frozen_sort).to be(true)
      expect(container.columns[0].sort_dir).to be_nil
      expect(container.columns[1].sort_dir).to be_nil
    end
  end

  describe "#alter_query" do
    it "allows the query to be modified" do
      pending_proposal = create(:proposal)
      approved = create(:proposal, status: "approved")
      container = TabularData::Container.new(:name, engine: "Proposal")

      expect(container.rows).to include(pending_proposal)
      expect(container.rows).to include(approved)

      new_container = container.alter_query { |p| p.closed }

      expect(new_container.rows).not_to include(pending_proposal)
      expect(new_container.rows).to include(approved)
    end
  end

  describe "#set_state_from_params" do
    let(:container) {
      config = {
        engine: "Proposal",
        column_configs: { id: true, client: { virtual: true }},
        columns: ["id", "client"]
      }
      TabularData::Container.new(:abc, config)
    }

    it "sets sort state if the field is valid" do
      first = create(:proposal)
      second = create(:proposal)
      third = create(:proposal)

      container.set_state_from_params(ActionController::Parameters.new(tables: { abc: { sort: "id" }}))

      expect(container.rows.to_a).to eq([first, second, third])

      container.set_state_from_params(ActionController::Parameters.new(tables: { abc: { sort: "-id" }}))

      expect(container.rows.to_a).to eq([third, second, first])
    end

    it "ignores invalid sorts" do
      create_list(:proposal, 3)
      invalids = [
        { tables: { abc: { sort: "client" }}},
        { tables: { abc: { sort: "asdasd" }}},
        { tables: { abc: "aaaa" }},
        { other: 2 }
      ]

      invalids.each do |invalid|
        container.set_state_from_params(ActionController::Parameters.new(invalid))
        expect(container.rows.length).to eq(3)
      end
    end
  end
end
