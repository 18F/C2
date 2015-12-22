shared_examples "client data" do
  describe "Associations" do
    it { should have_one(:proposal) }
    it { should have_many(:steps) }
    it { should have_many(:individual_steps) }
    it { should have_many(:approvers) }
    it { should have_many(:observations) }
    it { should have_many(:observers) }
    it { should have_many(:comments) }
    it { should have_one(:requester) }
    it { should have_many(:approvers) }
    it { should have_many(:purchasers) }
    it { should have_many(:completers) }
  end

  describe "Validations" do
    it { should validate_presence_of(:proposal) }
  end

  describe "Delegations" do
    it { should delegate_method(:add_observer).to(:proposal) }
    it { should delegate_method(:add_requester).to(:proposal) }
    it { should delegate_method(:currently_awaiting_step_users).to(:proposal) }
    it { should delegate_method(:set_requester).to(:proposal) }
    it { should delegate_method(:status).to(:proposal) }
  end

  describe "#slug_matches?" do
    it "is true when user passed in has same client slug" do
      client_data = build(factory_name)
      slug = client_data.client_slug
      user = build(:user, client_slug: slug)

      expect(client_data.slug_matches?(user)).to eq true
    end

    it "is false when the user has a differnet client slug" do
      client_data = build(factory_name)
      slug = client_data.client_slug
      user = build(:user, client_slug: "not #{slug}")

      expect(client_data.slug_matches?(user)).to eq false
    end
  end

  private

  def factory_name
    described_class.to_s.gsub("::", "").underscore
  end
end
