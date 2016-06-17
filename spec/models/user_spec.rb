describe User do
  describe "Associations" do
    it { should have_many(:steps).dependent(:destroy) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:observations).dependent(:destroy) }
    it { should have_many(:user_roles).dependent(:destroy) }
    it { should have_many(:proposals).dependent(:destroy) }
    it { should have_many(:reports) }
    it { should have_many(:scheduled_reports) }
    it { should have_many(:visits) }
    it { should have_many(:ahoy_events) }
  end

  let(:user) { build(:user) }

  context "valid attributes" do
    it "should be valid" do
      expect(user).to be_valid
    end
  end

  context "non-valid attributes" do
    it "missing email should not be valid" do
      user.email_address = nil
      expect(user).to_not be_valid
    end

    it "poorly formatted email should not be valid" do
      user.email_address = "foo@bar"
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

  describe ".for_email" do
    it "downcases and strips the email" do
      user = User.for_email("   miXedCaSe@eXaMple.com")
      expect(user.email_address).to eq("mixedcase@example.com")
    end

    it "raises error when email is empty" do
      expect do
        User.for_email("")
      end.to raise_error EmailRequired
    end
  end

  describe ".for_email_with_slug" do
    it "downcases and strips the email and adds slug" do
      user = User.for_email_with_slug("   miXedCaSe@eXaMple.com", "foobar")
      expect(user.email_address).to eq("mixedcase@example.com")
      expect(user.client_slug).to eq("foobar")
    end
  end

  describe ".with_role" do
    it "returns all users with a particular role name" do
      user1 = create(:user)
      user1.add_role("foo")
      user2 = create(:user)
      user2.add_role("bar")

      expect(User.with_role("bar")).to eq([user2])
    end
  end

  describe '#client_admin?' do
    it "returns false by default" do
      expect(user).to_not be_a_client_admin
    end

    it "returns true when the user is a client admin" do
      user.save!
      user.add_role("client_admin")
      expect(user).to be_a_client_admin
    end
  end

  describe '#gateway_admin?' do
    it "returns false by default" do
      expect(user).to_not be_a_client_admin
    end

    it "is true if the user has the gateway_admin role" do
      admin = create(:user, :gateway_admin)

      expect(admin).to be_gateway_admin
    end
  end

  describe '#admin?' do
    it "returns false by default" do
      expect(user).to_not be_a_client_admin
    end

    it "is true if the user has the admin role" do
      admin = create(:user, :admin)

      expect(admin).to be_admin
    end
  end

  describe "#any_admin?" do
    it "returns false by default" do
      expect(user).to_not be_any_admin
    end

    it "is true if the user has the admin role" do
      admin = create(:user, :admin)

      expect(admin).to be_any_admin
    end

    it "is true if the user has the gateway_admin role" do
      gateway_admin = create(:user, :gateway_admin)

      expect(gateway_admin).to be_any_admin
    end

    it "returns true when the user is a client admin" do
      client_admin = create(:user, :client_admin)

      expect(client_admin).to be_any_admin
    end
  end

  describe "#in_beta_program?" do
    it "returns false by default" do
      expect(user).to_not be_in_beta_program
    end
  end

  describe "#should_see_beta?" do
    it "returns false by default" do
      expect(user.should_see_beta?).to be false
    end

    it "is false if only the beta-active role is enabled" do
      misconfigured_user = create(:user)
      misconfigured_user.add_role(ROLE_BETA_ACTIVE)

      expect(misconfigured_user.should_see_beta?).to be false
    end

    it "is true if the user has the beta_active role with beta_user" do
      beta_active = create(:user)
      beta_active.add_role(ROLE_BETA_USER)
      beta_active.add_role(ROLE_BETA_ACTIVE)

      expect(beta_active.should_see_beta?).to be true
    end
  end

  describe "#revert_detail_design" do
    it "remove active but not beta_user" do
      beta_active = create(:user)
      beta_active.add_role(ROLE_BETA_USER)
      beta_active.add_role(ROLE_BETA_ACTIVE)

      beta_active.remove_role(ROLE_BETA_ACTIVE)
      expect(beta_active).to be_in_beta_program
    end

    it "remove beta_active" do
      beta_active = create(:user)
      beta_active.add_role(ROLE_BETA_USER)
      beta_active.add_role(ROLE_BETA_ACTIVE)

      beta_active.remove_role(ROLE_BETA_ACTIVE)
      expect(beta_active.should_see_beta?).to be false
    end

    it "doesn't remove other roles" do
      user = create(:user)
      user.add_role(ROLE_BETA_USER)
      user.add_role(ROLE_BETA_ACTIVE)
      user.add_role("admin")
      user.remove_role(ROLE_BETA_ACTIVE)

      expect(user).to be_admin
    end
  end

  describe '#not_admin?' do
    it "is true if the user does not have the admin role" do
      user = create(:user)

      expect(user).to be_not_admin
    end
  end

  describe "#deactivated?" do
    it "is true if user has active set to false" do
      user = build(:user, active: false)

      expect(user).to be_deactivated
    end

    it "is false when a user has active set to true" do
      user = build(:user, active: true)

      expect(user).not_to be_deactivated
    end
  end

  describe '#full_name' do
    it "return first name and last name" do
      user.first_name = "George"
      user.last_name = "Jetson"
      expect(user.full_name).to eq "George Jetson"
    end

    it "returns the user's email address if no first name and last name" do
      user.first_name = nil
      user.last_name = nil
      user.email_address = "george.jetson@example.com"

      expect(user.full_name).to eq "george.jetson@example.com"
    end

    it "returns the user's email address if the first name and last name are blank" do
      user.first_name = ""
      user.last_name = ""
      user.email_address = "george.jetson@example.com"

      expect(user.full_name).to eq "george.jetson@example.com"
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

    it "stringifies with #display_name" do
      user = create(:user)

      expect(user.to_s).to eq(user.display_name)
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

      expect do
        user.add_role(role.name)
      end.to change { user.roles.count }.from(0).to(1)
    end

    it "allows the user to immediately see its role" do
      user = create(:user)
      expect { user.add_role ROLE_BETA_USER }.to change { user.roles.size }.by(1)
    end
  end

  describe "#all_reports" do
    it "gets all private and shared-by-client_slug" do
      report = create(:report, shared: true, client_slug: "test")
      test_user = create(:user, client_slug: "test")
      report2 = create(:report, user: test_user)
      expect(test_user.all_reports).to include(report, report2)
    end
  end
end
