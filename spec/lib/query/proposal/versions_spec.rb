describe Query::Proposal::Versions do
  describe '.container' do
    it "limits to the specified Proposal" do
      prop1 = FactoryGirl.create(:proposal)
      prop2 = FactoryGirl.create(:proposal)

      container = Query::Proposal::Versions.container(prop1)
      rows = container.rows
      expect(rows).to eq(prop1.versions.reverse)
    end
  end
end
