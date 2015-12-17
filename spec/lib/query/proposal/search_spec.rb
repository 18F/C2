require 'ansi/code'

describe Query::Proposal::Search do

  before do
    refresh_index
  end

  describe '#execute' do
    it "returns an empty list for no Proposals" do
      user = create(:user, client_slug: "test")
      results = Query::Proposal::Search.new(current_user: user).execute('')
      expect(results.to_a).to eq([])
    end

    it "returns the Proposal when searching by ID" do
      test_client_request = create(:test_client_request)
      proposal = test_client_request.proposal
      proposal.reindex
      refresh_index
      results = Query::Proposal::Search.new(current_user: proposal.requester).execute(proposal.id.to_s)
      expect(results.to_a).to eq([proposal])
    end

    it "returns the Proposal when searching by public_id" do
      test_client_request = create(:test_client_request)
      proposal = test_client_request.proposal
      proposal.update_attribute(:public_id, 'foobar') # skip callback, which would overwrite this
      proposal.reindex
      refresh_index
      searcher = Query::Proposal::Search.new(current_user: proposal.requester)
      results = searcher.execute("foobar")
      expect(results.to_a).to eq([proposal])
    end

    it "can operate on an a relation" do
      test_client_request = create(:test_client_request)
      proposal = test_client_request.proposal
      proposal.reindex
      refresh_index
      relation = Proposal.where(id: proposal.id + 1)
      user = proposal.requester
      results = Query::Proposal::Search.new(relation: relation, current_user: user).execute(proposal.id.to_s)
      expect(results.to_a).to eq([])
    end

    it "returns an empty list for no matches" do
      test_client_request = create(:test_client_request)
      test_client_request.proposal.reindex
      refresh_index
      user = test_client_request.proposal.requester
      results = Query::Proposal::Search.new(current_user: user).execute('asgsfgsfdbsd')
      expect(results.to_a).to eq([])
    end

    context Ncr::WorkOrder do
      [:project_title, :description, :vendor].each do |attr_name|
        it "returns the Proposal when searching by the ##{attr_name}" do
          work_order = create(:ncr_work_order, attr_name => 'foo')
          work_order.proposal.reindex
          refresh_index
          results = Query::Proposal::Search.new(current_user: work_order.requester).execute('foo')
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
          results = Query::Proposal::Search.new(current_user: procurement.requester).execute('foo')
          expect(results.to_a).to eq([procurement.proposal])
        end
      end
    end

    it "returns the Proposals by rank" do
      user = create(:user, client_slug: "test")

      proposal1 = create(:proposal, id: 199, requester: user)
      test_client_request1 = create(:test_client_request, proposal: proposal1)
      proposal1.reindex

      test_client_request2 = create(:test_client_request, project_title: "199 rolly chairs for 1600 Penn Ave")
      proposal2 = test_client_request2.proposal
      test_client_request2.add_observer(user.email_address)
      proposal2.reindex

      proposal3 = create(:proposal, id: 1600, requester: user)
      test_client_request3 = create(:test_client_request, proposal: proposal3)
      proposal3.reindex

      refresh_index

      searcher = Query::Proposal::Search.new(current_user: user)
      expect(searcher.execute('199').to_a).to eq([proposal1, proposal2])
      expect(searcher.execute('1600').to_a).to eq([proposal3, proposal2])
      expect(searcher.execute('199 rolly').to_a).to eq([proposal2])
    end
  end
end

def refresh_index
  #puts ANSI.blue{ "----------------------------- REFRESHING INDEX ---------------------------------" }
  Proposal.__elasticsearch__.refresh_index!
end

def dump_index
  #puts ANSI.blue{ "----------------- DUMP INDEX ---------------------" }
  puts Proposal.search( "*" ).results.to_a.pretty_inspect
end
