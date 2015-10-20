describe User do
  let(:user) { build(:user) }

  context 'valid attributes' do
    it 'should be valid' do
      expect(user).to be_valid
    end
  end

  context 'non-valid attributes' do
    it 'missing email should not be valid' do
      user.email_address = nil
      expect(user).to_not be_valid
    end

    it 'poorly formatted email should not be valid' do
      user.email_address = 'foo@bar'
      expect(user).to_not be_valid
    end
  end


  describe '.for_email' do
    it 'downcases and strips the email' do
      user = User.for_email('   miXedCaSe@eXaMple.com')
      expect(user.email_address).to eq('mixedcase@example.com')
    end
  end

  describe '.with_role' do
    it 'returns all users with a particular Role' do
      user1 = create(:user)
      user1.add_role('foo')
      user2 = create(:user)
      user2.add_role('bar')

      expect(User.with_role('bar')).to eq([user2])
    end

    it 'returns all users with a particular role name' do
      user1 = create(:user)
      user1.add_role('foo')
      user2 = create(:user)
      user_role = user2.add_role('bar')

      expect(User.with_role(user_role.role)).to eq([user2])
    end
  end
  describe '#client_admin?' do
    it "returns false by default" do
      expect(user).to_not be_a_client_admin
    end

    it "returns true when the user is a client admin" do
      user.save!
      user.add_role('client_admin')
      expect(user).to be_a_client_admin
    end
  end

  describe '#admin?' do
    it 'is true of the user has the admin role' do
      admin = create(:user, :admin)

      expect(admin).to be_admin
    end
  end

  describe '#not_admin?' do
    it 'is true of the user does not have the admin role' do
      user = create(:user)

      expect(user).to be_not_admin
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
      user.email_address = 'george.jetson@example.com'

      expect(user.full_name).to eq 'george.jetson@example.com'
    end

    it "returns the user's email address if the first name and last name are blank" do
      user.first_name = ''
      user.last_name = ''
      user.email_address = 'george.jetson@example.com'

      expect(user.full_name).to eq 'george.jetson@example.com'
    end
  end

  describe '#has_role?' do
    before do
      user.save!
    end

    it 'can be assigned a role' do
      role = create(:role)
      user.add_role(role)
      expect(user).to have_role(role.name)
    end

    it 'can be assigned a role by role name' do
      role = create(:role)
      user.add_role(role.name)
      expect(user).to have_role(role)
    end
  end
end
