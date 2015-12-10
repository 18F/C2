describe Query::Proposal::Search do
  describe '#execute' do
    it "returns an empty list for no Proposals" do
      user = create(:user, client_slug: "test")
      results = Query::Proposal::Search.new(current_user: user).execute('')
      expect(results).to eq([])
    end

    it "returns the Proposal when searching by ID" do
      proposal = create(:proposal)
      proposal.requester.client_slug = "test"
      results = Query::Proposal::Search.new(current_user: proposal.requester).execute(proposal.id.to_s)
      expect(results).to eq([proposal])
    end

    it "returns the Proposal when searching by public_id" do
      proposal = create(:proposal)
      proposal.requester.client_slug = "test"
      # TODO must write to db to trigger reindex
      proposal.update_attribute(:public_id, 'foobar') # skip callback, which would overwrite this
      results = Query::Proposal::Search.new(current_user: proposal.requester).execute('foobar')
      expect(results).to eq([proposal])
    end

    it "can operate on an a relation" do
      proposal = create(:proposal)
      proposal.requester.client_slug = "test"
      relation = Proposal.where(id: proposal.id + 1)
      results = Query::Proposal::Search.new(relation: relation, current_user: proposal.requester).execute(proposal.id.to_s)
      expect(results).to eq([])
    end

    it "returns an empty list for no matches" do
      create(:proposal)
      proposal.requester.client_slug = "test"
      results = Query::Proposal::Search.new(current_user: proposal.requester).execute('asgsfgsfdbsd')
      expect(results).to eq([])
    end

    context Ncr::WorkOrder do
      [:project_title, :description, :vendor].each do |attr_name|
        it "returns the Proposal when searching by the ##{attr_name}" do
          work_order = create(:ncr_work_order, attr_name => 'foo')
          work_order.requester.client_slug = "ncr"
          results = Query::Proposal::Search.new(current_user: work_order.requester).execute('foo')
          expect(results).to eq([work_order.proposal])
        end
      end
    end

    context Gsa18f::Procurement do
      [:product_name_and_description, :justification, :additional_info].each do |attr_name|
        it "returns the Proposal when searching by the ##{attr_name}" do
          procurement = create(:gsa18f_procurement, attr_name => 'foo')
          procurement.requester.client_slug = "gsa18f"
          results = Query::Proposal::Search.new(current_user: procurement.requester).execute('foo')
          expect(results).to eq([procurement.proposal])
        end
      end
    end

    it "returns the Proposals by rank" do
      prop1 = create(:proposal, id: 12)
      test_client_data = create(:test_client_data, project_title: "12 rolly chairs for 1600 Penn Ave")
      prop2 = test_client_data.proposal
      prop3 = create(:proposal, id: 1600)

      searcher = Query::Proposal::Search.new
      expect(searcher.execute('12')).to eq([prop1, prop2])
      expect(searcher.execute('1600')).to eq([prop3, prop2])
      expect(searcher.execute('12 rolly')).to eq([prop2])
    end
  end
end
