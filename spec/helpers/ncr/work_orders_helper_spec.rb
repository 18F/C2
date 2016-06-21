describe Ncr::WorkOrdersHelper do
  before(:all) { ENV["DISABLE_EMAIL"] = nil }
  after(:all)  { ENV["DISABLE_EMAIL"] = "Yes" }

  describe '#scoped_approver_options' do
    it "includes existing users" do
      expect(helper.scoped_approver_options.size).to eq(0)
      users = create_list(:user, 2, client_slug: "ncr")

      expect(helper.scoped_approver_options).to match_array(users)
    end

    it "does not include inactive users" do
      inactive_approving_official = create(:user, :inactive, client_slug: "ncr")
      active_approving_official = create(:user, :active, client_slug: "ncr")

      expect(helper.scoped_approver_options).to include(
        active_approving_official
      )
      expect(helper.scoped_approver_options).not_to include(
        inactive_approving_official
      )
    end

    it 'sorts the results' do
      a_user = create(:user, email_address: 'b@example.com', client_slug: "ncr")
      b_user = create(:user, email_address: 'c@example.com', client_slug: "ncr")
      c_user = create(:user, email_address: 'a@example.com', client_slug: "ncr")
      d_user = create(:user, email_address: 'd@example.com', client_slug: 'gsa18f')
      expect(helper.scoped_approver_options).to match_array([
        a_user,
        b_user,
        c_user
      ])
      expect(helper.scoped_approver_options).not_to include(
        d_user
      )
    end
  end

  describe '#building_options' do
    it 'includes an initial list' do
      expect(helper.building_options).to include({ name: Ncr::BUILDING_NUMBERS.last })
    end

    it 'includes custom results' do
      create(:ncr_work_order, building_number: 'ABABABAB')
      expect(helper.building_options).to include({ name: 'ABABABAB' })
    end

    it 'removes duplicates from custom' do
      create(:ncr_work_order, building_number: 'ABABABAB')
      create(:ncr_work_order, building_number: 'ABABABAB')
      expect(helper.building_options.count({ name: 'ABABABAB' })).to be(1)
    end

    it 'removes duplicates when combining custom and initial list' do
      building = Ncr::BUILDING_NUMBERS.last
      create(:ncr_work_order, building_number: building)
      expect(helper.building_options.count({ name: building })).to be(1)
    end

    it 'sorts the results' do
      create(:ncr_work_order, building_number: 'BBB')
      create(:ncr_work_order, building_number: 'CCC')
      create(:ncr_work_order, building_number: 'AAA')
      a_index = helper.building_options.index({ name: 'AAA' })
      b_index = helper.building_options.index({ name: 'BBB' })
      c_index = helper.building_options.index({ name: 'CCC' })
      expect(a_index).to be < b_index
      expect(a_index).to be < c_index
      expect(b_index).to be < c_index
    end
  end
end
