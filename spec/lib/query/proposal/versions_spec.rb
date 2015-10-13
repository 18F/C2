describe Query::Proposal::Versions do
  describe '.container' do
    it "limits to the specified Proposal" do
      prop1 = create(:proposal)
      prop2 = create(:proposal)

      container = Query::Proposal::Versions.container(prop1)
      expect(container.rows).to eq(prop1.versions.reverse)
    end

    it "includes approvals" do
      prop1 = create(:proposal, :with_approver)
      prop2 = create(:proposal, :with_approver)

      container = Query::Proposal::Versions.container(prop1)
      approval = prop1.approvals.first
      expect(container.rows).to include(approval.versions.first)
    end
  end
end
