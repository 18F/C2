describe Ncr::WorkOrdersHelper do
  describe '#building_options' do
    let(:user) { FactoryGirl.create(:user) }

    before do
      expect(helper).to receive(:current_user).and_return(user)
    end

    it "returns the buildings from the YAML file" do
      expect(helper.building_options.size).to eq(Ncr::Building.all.size)
    end

    it "includes buildings from the user's past work orders" do
      work_order = FactoryGirl.create(:ncr_work_order, requester: user, building_number: "Toad's Turnpike")
      expect(helper.building_options).to include(text: "Toad's Turnpike", value: "Toad's Turnpike")
    end

    it "deduplicates building entries"
  end
end
