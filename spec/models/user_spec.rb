describe User do
  let(:user) { FactoryGirl.build(:user) }

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

  describe '#client_admin?' do
    it "returns false by default" do
      expect(user).to_not be_a_client_admin
    end

    with_env_var 'CLIENT_ADMIN_EMAILS', 'admin1@some-dot-gov.gov,admin2@some-dot-gov.gov' do
      it "returns false" do
        expect(user).to_not be_a_client_admin
      end

      it "returns true when the email is listed" do
        user.email_address = 'admin2@some-dot-gov.gov'
        expect(user).to be_a_client_admin
      end
    end
  end

  describe '#full_name' do
    it 'return first name and last name' do
      user.first_name = 'George'
      user.last_name = 'Jetson'
      expect(user.full_name).to eq 'George Jetson'
    end

    it "returns the user's email address if no first name and last name" do
      user.first_name = nil
      user.last_name = nil
      user.email_address = 'george.jetson@spacelysprockets.com'

      expect(user.full_name).to eq 'george.jetson@spacelysprockets.com'
    end
  end

  describe '.for_email' do
    it "downcases and strips the email" do
      user = User.for_email('   miXedCaSe@some-doT-gov.gov')
      expect(user.email_address).to eq('mixedcase@some-dot-gov.gov')
    end
  end
end
