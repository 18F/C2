describe ProposalVersionsQuery do
  before(:each) { PaperTrail.enabled = true }
  after(:each) { PaperTrail.enabled = false }

  describe '#container' do
    it "limits to the specified Proposal" do
      prop1 = create(:proposal)
      _prop2 = create(:proposal)

      container = ProposalVersionsQuery.new(prop1).container
      expect(container.rows).to eq(prop1.versions.reverse)
    end

    xit "includes approvals" do
      prop1 = create(:proposal, :with_approver)

      container = ProposalVersionsQuery.new(prop1).container
      approval = prop1.steps.first
      expect(container.rows).to include(approval.versions.first)
    end
  end
end
