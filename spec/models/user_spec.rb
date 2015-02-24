describe User do

  let(:user) { FactoryGirl.create(:user, first_name: "George", last_name: "Jetson") }

  context 'valid attributes' do
    it 'should be valid' do
      expect(user).to be_valid
    end
  end

  context 'non-valid attributes' do
    it 'should not be valid' do
      user.email_address = nil
      expect(user).to_not be_valid
    end
  end


  describe '#full_name' do
    it 'return first name and last name' do
      expect(user.full_name).to eq 'George Jetson'
    end

    it "returns the user's email address if no first name and last name" do
      user.first_name = nil
      user.last_name = nil
      user.email_address = 'george.jetson@spacelysprockets.com'

      expect(user.full_name).to eq 'george.jetson@spacelysprockets.com'
    end
  end

  describe '#approver_of?' do
    let(:cart) { FactoryGirl.create(:cart) }

    it 'returns true when user is an approver' do
      cart.add_approver user.email_address
      expect(user.approver_of? cart).to eq true
    end

    it 'returns false when user is not an approver' do
      expect(user.approver_of? cart).to eq false
    end
  end
end
