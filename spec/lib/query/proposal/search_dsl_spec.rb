describe Query::Proposal::SearchDSL do
  it "combines query strings and client-data-specific hash" do
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
            { term: { subscribers: user.id.to_s } }
          ]
        }
      },
      size: 5,
      from: 1
    })
  end
end
