describe Ncr::WorkOrdersHelper do
  describe '#approver_options' do
    it 'includes existing users' do
      expect(helper.approver_options.size).to eq(2)  # seed Users
      users = [create(:user, client_slug: 'ncr'), create(:user, client_slug: 'ncr')]
      expect(helper.approver_options).to include(*users.map(&:email_address))
    end

    it 'sorts the results' do
      create(:user, email_address: 'b@example.com', client_slug: 'ncr')
      create(:user, email_address: 'c@example.com', client_slug: 'ncr')
      create(:user, email_address: 'a@example.com', client_slug: 'ncr')
      create(:user, email_address: 'd@example.com', client_slug: 'gsa18f')
      expect(helper.approver_options).to include(*%w(a@example.com b@example.com c@example.com))
      expect(helper.approver_options).not_to include(*%w(d@example.com))
    end
  end

  describe '#building_options' do
    it 'includes an initial list' do
      expect(helper.building_options).to include(Ncr::BUILDING_NUMBERS.last)
    end

    it 'includes custom results' do
      create(:ncr_work_order, building_number: 'ABABABAB')
      expect(helper.building_options).to include('ABABABAB')
    end

    it 'removes duplicates from custom' do
      create(:ncr_work_order, building_number: 'ABABABAB')
      create(:ncr_work_order, building_number: 'ABABABAB')
      expect(helper.building_options.count('ABABABAB')).to be(1)
    end

    it 'removes duplicates when combining custom and initial list' do
      building = Ncr::BUILDING_NUMBERS.last
      create(:ncr_work_order, building_number: building)
      expect(helper.building_options.count(building)).to be(1)
    end

    it 'sorts the results' do
      create(:ncr_work_order, building_number: 'BBB')
      create(:ncr_work_order, building_number: 'CCC')
      create(:ncr_work_order, building_number: 'AAA')
      a_index = helper.building_options.index('AAA')
      b_index = helper.building_options.index('BBB')
      c_index = helper.building_options.index('CCC')
      expect(a_index).to be < b_index
      expect(a_index).to be < c_index
      expect(b_index).to be < c_index
    end
  end
end
