describe Query::Proposal::SearchDSL do
  it "combines query strings and client-data-specific hash" do
    dsl = Query::Proposal::SearchDSL.new(
      params: { 
        from: 1, 
        size: 5, 
        foo_bar_baz: { 
          color: "green" 
        }
      },
      query: 'foo OR Bar',
      client_data_type: 'Foo::BarBaz'
    )
    expect(dsl.to_hash).to eq({
      query: {
        filtered: {
          query: {
            match: {
              query: "(foo OR Bar) AND (color:green)", 
              operator: "and"
            }
          },
          filter: {
            term: {
              client_data_type: "Foo::BarBaz"
            }
          }
        }
      },
      size: 5,
      from: 1
    })
  end
end
