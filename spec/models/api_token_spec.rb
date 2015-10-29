describe ApiToken do
  describe "Validations" do
    it { should validate_presence_of(:approval) }
    it { should validate_presence_of(:expires_at).on(:save) }
    it { should validate_presence_of(:access_token).on(:save) }
    it { should validate_uniqueness_of(:access_token) }
  end

  describe "#used?" do
    it "is true if used_at is set" do
      token = build(:api_token, used_at: Time.current)

      expect(token).to be_used
    end

    it "is false if used_at is nil" do
      token = build(:api_token, used_at: nil)

      expect(token).not_to be_used
    end
  end

  describe "#expired?" do
    it "is true if expires_at datetime is before now" do
      token = build(:api_token, expires_at: 1.day.ago)

      expect(token).to be_expired
    end

    it "is false if expires_at datetime is not set" do
      token = build(:api_token, expires_at: nil)

      expect(token).not_to be_expired
    end

    it "is false if expires_at datetime is in future" do
      token = create(:api_token, expires_at: 1.day.from_now)

      expect(token).not_to be_expired
    end
  end

  describe "#use!" do
    it "updates used_at to equal current time" do
      Timecop.freeze do
        time = Time.current
        token = create(:api_token, used_at: nil)

        token.use!

        expect(token.used_at).to eq time
      end
    end
  end
end
