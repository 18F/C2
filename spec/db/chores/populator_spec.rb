require "#{Rails.root}/db/chores/populator"

describe Populator do
  before(:all) { DatabaseCleaner.strategy = :truncation }
  after(:all) { DatabaseCleaner.strategy = :transaction }

  describe '#random_ncr_data' do
    it "creates the specified number of work orders" do
      num_proposals = 5
      expect do
        Populator.new.random_ncr_data(num_proposals: num_proposals)
      end.to change { Ncr::WorkOrder.count }.from(0).to(num_proposals)
    end
  end

  describe '#uniform_ncr_data' do
    it "creates the specified number of work orders" do
      n = 5
      expect do
        Populator.new.uniform_ncr_data(n: n)
      end.to change { Ncr::WorkOrder.count }.from(0).to(n)
    end
  end

  describe '#ncr_data_for_user' do
    it "creates proposals for the user with email address passed in" do
      email = "test@example.com"
      num_proposals = 2
      user = create(:user, email_address: email)

      expect do
        Populator.new.ncr_data_for_user(email: email, num_proposals: num_proposals)
      end.to change { user.proposals.count }.from(0).to(num_proposals)
    end
  end
end
