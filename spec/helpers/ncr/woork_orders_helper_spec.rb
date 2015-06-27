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
end
