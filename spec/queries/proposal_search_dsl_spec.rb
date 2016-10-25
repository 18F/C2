describe ProposalSearchDsl do
  it "#to_hash" do
    user = create(:user, client_slug: "test")
    dsl = ProposalSearchDsl.new(
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
            { term: { client_slug: "test" } },
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
    dsl = ProposalSearchDsl.new(
      params: {
        test_client_request: {
          color: "green"
        }
      },
      query: "foo OR Bar",
      current_user: user,
      client_data_type: "Test::ClientRequest"
    )
    expect(dsl.to_hash[:size]).to eq Proposal::MAX_SEARCH_RESULTS
    expect(dsl.to_hash[:from]).to eq 0
  end

  it "determines from/size from page param" do
    user = create(:user, client_slug: "test")
    dsl = ProposalSearchDsl.new(
      params: {
        page: 3
      },
      query: "foo OR Bar",
      current_user: user,
      client_data_type: "Test::ClientRequest"
    )
    expect(dsl.to_hash[:size]).to eq Proposal::MAX_SEARCH_RESULTS
    expect(dsl.to_hash[:from]).to eq( 2 * Proposal::MAX_SEARCH_RESULTS )
  end

  describe "parses date ranges" do
    it "when created_at is present" do
      some_time = Time.zone.parse("2016-03-25T02:55:57Z")
      user = create(:user, client_slug: "test")
      dsl = ProposalSearchDsl.new(
        params: {
          test_client_request: {
            created_at: some_time.to_s,
            created_within: "6 months",
          }
        },
        query: "foo OR Bar",
        current_user: user,
        client_data_type: "Test::ClientRequest"
      )
      expect(dsl.composite_query_string).to eq(
        "(foo OR Bar) AND (created_at:[#{(some_time.utc - 6.months).iso8601} TO #{some_time.utc.iso8601}])"
      )
    end

    it "when created_at is not present defaults to relative-to-now" do
      Timecop.freeze do
        six_months_ago = (Time.current.utc - 6.months).iso8601
        user = create(:user, client_slug: "test")
        dsl = ProposalSearchDsl.new(
          params: {
            test_client_request: {
              created_within: "6 months",
            }
          },
          query: "foo OR Bar",
          current_user: user,
          client_data_type: "Test::ClientRequest"
        )
        expect(dsl.composite_query_string).to eq(
          "(foo OR Bar) AND (created_at:[#{six_months_ago} TO now])"
        )
      end
    end
  end

  it "#client_query" do
    user = create(:user, client_slug: "test")
    dsl = ProposalSearchDsl.new(
      params: {
        test_client_request: {
          amount: "123"
        }
      },
      query: "foo OR Bar",
      current_user: user,
      client_data_type: user.client_model.to_s
    )
    expect(dsl.client_query).to be_a ProposalFieldedSearchQuery
    expect(dsl.client_query.to_s).to eq "amount:(123)"
  end

  it "#composite_query_string" do
    user = create(:user, client_slug: "test")
    dsl = ProposalSearchDsl.new(
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
    dsl = ProposalSearchDsl.new(
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
