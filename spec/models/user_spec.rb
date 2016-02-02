describe User do
  describe "Associations" do
     it { should have_many(:steps).dependent(:destroy) }
     it { should have_many(:comments).dependent(:destroy) }
     it { should have_many(:observations).dependent(:destroy) }
     it { should have_many(:user_roles).dependent(:destroy) }
     it { should have_many(:proposals).dependent(:destroy) }
  end

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

  describe ".active" do
    it "returns users with active set to true" do
      User.destroy_all
      active = create(:user, :active)
      _inactive = create(:user, :inactive)

      expect(User.active).to eq [active]
    end
  end

  describe '.for_email' do
    it 'downcases and strips the email' do
      user = User.for_email('   miXedCaSe@eXaMple.com')
      expect(user.email_address).to eq('mixedcase@example.com')
    end
  end

  describe ".for_email_with_slug" do
    it "downcases and strips the email and adds slug" do
      user = User.for_email_with_slug('   miXedCaSe@eXaMple.com', 'foobar')
      expect(user.email_address).to eq('mixedcase@example.com')
      expect(user.client_slug).to eq('foobar')
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

      expect(User.with_role(user_role.role.name)).to eq([user2])
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

  describe "#deactivated?" do
    it "is true of user has active set to false" do
      user = build(:user, active: false)

      expect(user).to be_deactivated
    end

    it "is false when a user has active set to true" do
      user = build(:user, active: true)

      expect(user).not_to be_deactivated
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

  describe "#display_name" do
    it "uses full_name if not equal to email_address" do
      user.first_name = "George"
      user.last_name = "Jetson"
      user.email_address = "george.jetson@example.com"
      expect(user.display_name).to eq "George Jetson <george.jetson@example.com>"
    end

    it "returns the user's email address if no first name and last name" do
      user.first_name = nil
      user.last_name = nil
      user.email_address = "george.jetson@example.com"

      expect(user.display_name).to eq "george.jetson@example.com"
    end

    it "returns the user's email address if the first name and last name are blank" do
      user.first_name = ""
      user.last_name = ""
      user.email_address = "george.jetson@example.com"

      expect(user.display_name).to eq "george.jetson@example.com"
    end
  end

  describe "#requires_profile_attention?" do
    it "recognizes user needs to update their profile" do
      user = create(:user)
      expect(user.requires_profile_attention?).to eq false
      user.first_name = ""
      user.save!
      expect(user.requires_profile_attention?).to eq true
    end
  end

  describe "#client_model" do
    it "matches client_slug with client model name" do
      user = create(:user, client_slug: "test")
      expect(user.client_model).to eq Test::ClientRequest
    end
  end

  describe "#client_model_slug" do
    it "turns client_model into a slug" do
      user = create(:user, client_slug: "test")
      expect(user.client_model_slug).to eq "test_client_request"
    end
  end

  describe "#add_role" do
    it "adds role by name" do
      user = create(:user)
      role = create(:role)

      expect {
        user.add_role(role.name)
      }.to change { user.roles.count }.from(0).to(1)
    end
  end
end
