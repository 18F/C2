describe Query::Proposal::SearchDSL do
  it "#to_hash" do
    user = create(:user, client_slug: "test")
    dsl = Query::Proposal::SearchDSL.new(
      params: {
        from: 1,
        size: 5,
        test_client_request: {
          color: "green"
        }
      },
      query: "foo OR Bar",
      current_user: user,
      client_data_type: "Test::ClientRequest"
    )
    expect(dsl.to_hash).to eq({
      _source: ["id"],
      query: {
        query_string: {
          query: "(foo OR Bar) AND (color:(green))",
          default_operator: "and"
        },
      },
      filter: {
        bool: {
          must: [
            { term: { client_data_type: "Test::ClientRequest" } },
            { term: { "subscribers.id" => user.id.to_s } }
          ]
        }
      },
      size: 5,
      from: 1
    })
  end

  it "defaults to sane pagination" do
    user = create(:user, client_slug: "test")
    dsl = Query::Proposal::SearchDSL.new(
      params: {
        test_client_request: {
          color: "green"
        }
      },
      query: "foo OR Bar",
      current_user: user,
      client_data_type: "Test::ClientRequest"
    )
    expect(dsl.to_hash[:size]).to eq ::Proposal::MAX_SEARCH_RESULTS
    expect(dsl.to_hash[:from]).to eq 0
  end

  it "determines from/size from page param" do
    user = create(:user, client_slug: "test")
    dsl = Query::Proposal::SearchDSL.new(
      params: {
        page: 3
      },
      query: "foo OR Bar",
      current_user: user,
      client_data_type: "Test::ClientRequest"
    )
    expect(dsl.to_hash[:size]).to eq ::Proposal::MAX_SEARCH_RESULTS
    expect(dsl.to_hash[:from]).to eq( 2 * ::Proposal::MAX_SEARCH_RESULTS )
  end

  it "parses date ranges" do
    now = Time.zone.now
    user = create(:user, client_slug: "test")
    dsl = Query::Proposal::SearchDSL.new(
      params: {
        test_client_request: {
          created_at: now.to_s,
          created_within: "6 months",
        }
      },
      query: "foo OR Bar",
      current_user: user,
      client_data_type: "Test::ClientRequest"
    )
    expect(dsl.client_query.to_s).to eq "created_at:[#{now.utc - 6.months} TO #{now.utc}]"
  end

  it "#client_query" do
    user = create(:user, client_slug: "test")
    dsl = Query::Proposal::SearchDSL.new(
      params: {
        test_client_request: {
          amount: "123"
        }
      },
      query: "foo OR Bar",
      current_user: user,
      client_data_type: user.client_model.to_s
    )
    expect(dsl.client_query).to be_a Query::Proposal::FieldedSearch
    expect(dsl.client_query.to_s).to eq "amount:(123)"
  end

  it "#composite_query_string" do
    user = create(:user, client_slug: "test")
    dsl = Query::Proposal::SearchDSL.new(
      params: {
        test_client_request: {
          amount: "123"
        }
      },
      query: "foo OR Bar",
      current_user: user,
      client_data_type: user.client_model.to_s
    )
    expect(dsl.composite_query_string).to eq "(foo OR Bar) AND (amount:(123))"
  end

  it "#humanized_query_string" do
    user = create(:user, client_slug: "test")
    dsl = Query::Proposal::SearchDSL.new(
      params: {
        test_client_request: {
          amount: "123"
        }
      },
      query: "foo OR Bar",
      current_user: user,
      client_data_type: user.client_model.to_s
    )
    expect(dsl.humanized_query_string).to eq "(foo OR Bar) AND (Amount:(123))"
  end
end
