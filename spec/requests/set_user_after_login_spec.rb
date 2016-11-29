describe "User creation when logging in with Oauth to view a protected page" do
  include EnvVarSpecHelper

  StructUser = Struct.new(:email_address, :first_name, :last_name)

  before do
    user = StructUser.new("george-test@example.com", "Georgie", "Jetsonian")
    setup_mock_auth(:cg, user)
  end

  it "creates a new user if the current user does not already exist" do
    expect do
      get "/auth/cg/callback"
    end.to change { User.count }.by(1)

    new_user = User.last
    expect(new_user.email_address).to eq("george-test@example.com")
    expect(new_user.first_name).to eq("Georgie")
    expect(new_user.last_name).to eq("Jetsonian")
  end

  it "sends welcome email to a new user", :email do
    with_env_var("WELCOME_EMAIL", "true") do
      expect { get "/auth/cg/callback" }.to change { deliveries.length }.from(0).to(1)
      welcome_mail = deliveries.first
      expect(welcome_mail.subject).to eq("Welcome to C2!")
    end
  end

  it "absence of first/last name does not throw error" do
    user = StructUser.new("somebody@example.com", nil, nil)
    setup_mock_auth(:cg, user)
    expect do
      get "/auth/cg/callback"
    end.to change { User.count }.by(1)
  end

  it "does not create a user if the current user already exists" do
    create(:user, email_address: "george-test@example.com")

    expect do
      get "/auth/cg/callback"
    end.to_not change { User.count }
  end

  it "does not send welcome email to existing user" do
    deliveries.clear
    create(:user, email_address: "george-test@example.com")

    Timecop.travel(Time.current + 1.minute) do
      expect do
        get "/auth/cg/callback"
      end.to_not change { deliveries.length }
    end
  end

  it "redirects a newly logged in user to the carts screen" do
    create(:user, email_address: "george-test@example.com")

    expect do
      get "/auth/cg/callback"
    end.to_not change { User.count }

    expect(response).to redirect_to("/proposals")
  end
end
