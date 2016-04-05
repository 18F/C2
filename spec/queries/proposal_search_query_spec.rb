require 'ansi/code'

describe ProposalSearchQuery, elasticsearch: true do
  before do
    # analogous to DatabaseCleaner.start in spec/rails_helper
    refresh_index
  end

  describe '#execute' do
    it "raises custom error when Elasticsearch is not available" do
      es_mock_connection_failed
      user = create(:user, client_slug: "test")
      searcher = ProposalSearchQuery.new(current_user: user)
      expect {
        searcher.execute("foobar")
      }.to raise_error(SearchUnavailable, I18n.t("errors.features.es.service_unavailable"))
    end

    it "raises custom error when we feed Elasticsearch faulty search syntax" do
      user = create(:user, client_slug: "test")
      searcher = ProposalSearchQuery.new(current_user: user)
      expect {
        searcher.execute("ffo)")
      }.to raise_error(SearchBadQuery, I18n.t("errors.features.es.bad_query"))
    end

    it "returns an empty list for no Proposals" do
      user = create(:user, client_slug: "test")
      searcher = ProposalSearchQuery.new(current_user: user)
      es_execute_with_retries 3 do
        results = searcher.execute('')
        expect(results.to_a).to eq([])
      end
    end

    it "returns the Proposal when searching by ID" do
      test_client_request = create(:test_client_request)
      proposal = test_client_request.proposal
      proposal.reindex
      refresh_index
      es_execute_with_retries 3 do
        results = ProposalSearchQuery.new(current_user: proposal.requester).execute(proposal.id.to_s)
        expect(results.to_a).to eq([proposal])
      end
    end

    it "returns the Proposal when searching by public_id" do
      test_client_request = create(:test_client_request)
      proposal = test_client_request.proposal
      proposal.update_attribute(:public_id, 'foobar') # skip callback, which would overwrite this
      proposal.reindex
      refresh_index
      es_execute_with_retries 3 do
        searcher = ProposalSearchQuery.new(current_user: proposal.requester)
        results = searcher.execute("foobar")
        expect(results.to_a).to eq([proposal])
      end
    end

    it "can operate on an a relation" do
      test_client_request = create(:test_client_request)
      proposal = test_client_request.proposal
      proposal.reindex
      refresh_index
      relation = Proposal.where(id: proposal.id + 1)
      user = proposal.requester
      es_execute_with_retries 3 do
        results = ProposalSearchQuery.new(relation: relation, current_user: user).execute(proposal.id.to_s)
        expect(results.to_a).to eq([])
      end
    end

    it "returns an empty list for no matches" do
      test_client_request = create(:test_client_request)
      test_client_request.proposal.reindex
      refresh_index
      user = test_client_request.proposal.requester
      es_execute_with_retries 3 do
        results = ProposalSearchQuery.new(current_user: user).execute('asgsfgsfdbsd')
        expect(results.to_a).to eq([])
      end
    end

    context Ncr::WorkOrder do
      [:project_title, :description, :vendor].each do |attr_name|
        it "returns the Proposal when searching by the ##{attr_name}" do
          work_order = create(:ncr_work_order, attr_name => 'foo')
          work_order.proposal.reindex
          refresh_index
          es_execute_with_retries 3 do
            results = ProposalSearchQuery.new(current_user: work_order.requester).execute('foo')
            expect(results.to_a).to eq([work_order.proposal])
          end
        end
      end

      it "returns the Proposal when searching ncr_organization by name" do
        whsc_org = create(:whsc_organization)
        work_order = create(:ncr_work_order, ncr_organization: whsc_org)
        work_order.proposal.reindex
        refresh_index
        es_execute_with_retries 3 do
          results = ProposalSearchQuery.new(current_user: work_order.requester).execute(whsc_org.code)
          expect(results.to_a).to eq([work_order.proposal])
        end
      end

      it "returns the Proposal when searching approving_official by name" do
        work_order = create(:ncr_work_order)
        work_order.proposal.reindex
        refresh_index
        approving_official = work_order.approving_official
        es_execute_with_retries 3 do
          results = ProposalSearchQuery.new(current_user: work_order.requester).execute(approving_official.email_address)
          expect(results.to_a).to eq([work_order.proposal])
          results = ProposalSearchQuery.new(current_user: work_order.requester).execute(approving_official.full_name)
          expect(results.to_a).to eq([work_order.proposal])
        end
      end
    end

    context Gsa18f::Procurement do
      [:product_name_and_description, :justification, :additional_info].each do |attr_name|
        it "returns the Proposal when searching by the ##{attr_name}" do
          procurement = create(:gsa18f_procurement, attr_name => 'foo')
          procurement.proposal.reindex
          refresh_index
          es_execute_with_retries 3 do
            results = ProposalSearchQuery.new(current_user: procurement.requester).execute('foo')
            expect(results.to_a).to eq([procurement.proposal])
          end
        end
      end
    end

    it "returns the Proposals by rank, weighting id matches above all else" do
      # explicit db clean call here because we are manually assigning IDs
      # and auto-retry means we must avoid collisions.
      DatabaseCleaner.start

      user = create(:user, client_slug: "test")

      proposal1 = create(:proposal, id: 199, requester: user)
      create(:test_client_request, proposal: proposal1)
      proposal1.reindex

      test_client_request2 = create(:test_client_request, project_title: "199 rolly chairs for 1600 Penn Ave")
      proposal2 = test_client_request2.proposal
      test_client_request2.add_observer(user)
      proposal2.reindex

      proposal3 = create(:proposal, id: 1600, requester: user)
      create(:test_client_request, proposal: proposal3)
      proposal3.reindex

      refresh_index

      es_execute_with_retries 3 do
        searcher = ProposalSearchQuery.new(current_user: user)
        expect(searcher.execute('199').to_a).to eq([proposal1, proposal2])
        expect(searcher.execute('1600').to_a).to eq([proposal3, proposal2])
        expect(searcher.execute('199 rolly').to_a).to eq([proposal2])
      end
    end
  end
end

def refresh_index
  if ENV["ES_DEBUG"]
    puts ANSI.blue{ "----------------------------- REFRESHING INDEX ---------------------------------" }
  end
  Proposal.__elasticsearch__.refresh_index!
end

def dump_index
  if ENV["ES_DEBUG"]
    puts ANSI.blue{ "----------------- DUMP INDEX ---------------------" }
    puts Proposal.search( "*" ).results.pretty_inspect
  end
end
