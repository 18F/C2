describe Ncr::WorkOrdersHelper do
  describe '#approver_options' do
    it 'includes existing users' do
      expect(helper.approver_options).to be_empty
      users = [FactoryGirl.create(:user), FactoryGirl.create(:user)]
      expect(helper.approver_options).to eq(users.map(&:email_address))
    end

    it 'sorts the results' do
      FactoryGirl.create(:user, email_address: 'b@ex.com')
      FactoryGirl.create(:user, email_address: 'c@ex.com')
      FactoryGirl.create(:user, email_address: 'a@ex.com')
      expect(helper.approver_options).to eq(%w(a@ex.com b@ex.com c@ex.com))
    end
  end

  describe '#building_options' do
    let(:user) { FactoryGirl.create(:user) }
    let(:values) { helper.building_options.map{|opt| opt[:value] } }

    before do
      expect(helper).to receive(:current_user).and_return(user)
    end

    it 'includes an initial list' do
      building = Ncr::Building.all.last
      expect(values).to include(building.number)
    end

    it 'includes custom results' do
      FactoryGirl.create(:ncr_work_order, requester: user, building_number: 'ABABABAB')
      expect(values).to include('ABABABAB')
    end

    it 'removes duplicates from custom' do
      FactoryGirl.create(:ncr_work_order, requester: user, building_number: 'ABABABAB')
      FactoryGirl.create(:ncr_work_order, requester: user, building_number: 'ABABABAB')
      expect(values.count('ABABABAB')).to eq(1)
    end

    it 'removes duplicates when combining custom and initial list' do
      building = Ncr::Building.all.last
      FactoryGirl.create(:ncr_work_order, requester: user, building_number: building)
      expect(values.count(building.number)).to eq(1)
    end

    it 'sorts the results' do
      FactoryGirl.create(:ncr_work_order, requester: user, building_number: 'BBB')
      FactoryGirl.create(:ncr_work_order, requester: user, building_number: 'CCC')
      FactoryGirl.create(:ncr_work_order, requester: user, building_number: 'AAA')

      a_index = values.index('AAA')
      b_index = values.index('BBB')
      c_index = values.index('CCC')
      expect(a_index).to be < b_index
      expect(a_index).to be < c_index
      expect(b_index).to be < c_index
    end
  end
end
