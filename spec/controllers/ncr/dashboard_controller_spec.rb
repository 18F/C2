describe Ncr::DashboardController do
  describe '#index' do
    let (:user) {FactoryGirl.create(:user)}
    before do
      login_as(user)
    end

    it 'does not include proposals user did not participate in' do
      FactoryGirl.create(:ncr_work_order)
      get :index
      expect(assigns(:rows)).to be_empty
    end

    it 'groups by month and aggregates' do
      # 2 in January, 3 in February, 3 in March
      (1..8).each {|i|
        FactoryGirl.create(
          :ncr_work_order, requester: user, created_at: Date.new(2015, i / 3 + 1, i),
          amount: i)
      }
      get :index
      rows = assigns(:rows)
      expect(rows.length).to be(3)  # Jan, Feb, March
      rows.each {|row| expect(row[:year]).to eq(2015)}
      mar, feb, jan = rows

      expect(mar[:month]).to eq("Mar")
      expect(mar[:count]).to eq(3)
      expect(mar[:cost]).to eq(6 + 7 + 8)

      expect(feb[:month]).to eq("Feb")
      expect(feb[:count]).to eq(3)
      expect(feb[:cost]).to eq(3 + 4 + 5)

      expect(jan[:month]).to eq("Jan")
      expect(jan[:count]).to eq(2)
      expect(jan[:cost]).to eq(1 + 2)
    end

    it 'includes months with no proposals'   # @todo
  end
end
