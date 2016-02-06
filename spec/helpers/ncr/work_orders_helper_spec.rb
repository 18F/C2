describe Ncr::WorkOrdersHelper do
  describe '#approver_options' do
    it 'includes existing users' do
      expect(helper.approver_options.size).to eq(0)
      users = [create(:user, client_slug: "ncr"), create(:user, client_slug: "ncr")]
      users.map do |user|
        expect(helper.approver_options).to include({
          name: user.email_address,
          id: user.id
        })
      end
    end

    it "does not include inactive users" do
      inactive_approving_official = create(:user, :inactive, client_slug: "ncr")
      active_approving_official = create(:user, :active, client_slug: "ncr")

      expect(helper.approver_options).to include({
        name: active_approving_official.email_address,
        id: active_approving_official.id
      })
      expect(helper.approver_options).not_to include({
        name: inactive_approving_official.email_address,
        id: inactive_approving_official.id
      })
    end

    it 'sorts the results' do
      a_user = create(:user, email_address: 'b@example.com', client_slug: "ncr")
      b_user = create(:user, email_address: 'c@example.com', client_slug: "ncr")
      c_user = create(:user, email_address: 'a@example.com', client_slug: "ncr")
      d_user = create(:user, email_address: 'd@example.com', client_slug: 'gsa18f')
      expect(helper.approver_options).to include(
        { name: a_user.email_address, id: a_user.id },
        { name: b_user.email_address, id: b_user.id },
        { name: c_user.email_address, id: c_user.id }
        )
      expect(helper.approver_options).not_to include(
        { name: d_user.email_address, id: d_user.id }
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
