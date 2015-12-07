describe Gsa18f::Procurement do
  it_behaves_like "client data"

  describe "Validations" do
    it { should validate_presence_of(:purchase_type) }
  end

  describe ".relevant_fields" do
    it "returns recurring fields if recurring is true" do
      fields = Gsa18f::Procurement.relevant_fields(true)

      expect(fields).to include(:recurring_interval)
      expect(fields).to include(:recurring_length)
    end

    it "does not return recurring fields if recurring is false" do
      fields = Gsa18f::Procurement.relevant_fields(false)

      expect(fields).not_to include(:recurring_interval)
      expect(fields).not_to include(:recurring_length)
    end
  end

  it "sets up initial approvers and observers" do
    DatabaseCleaner.clean_with(:truncation)
    Rails.application.load_seed
    procurement = create(:gsa18f_procurement, :with_steps)
    expect(procurement.approvers.map(&:email_address)).to eq(["some.approver@example.com", "some.purchaser@example.com"])
    expect(procurement.observers.map(&:email_address)).to be_empty
    expect(procurement.purchaser.email_address).to eq("some.purchaser@example.com")
  end

  it "identifies eligible observers based on client_slug" do
    procurement = create(:gsa18f_procurement)
    user = create(:user, client_slug: 'gsa18f')
    expect(procurement.proposal.eligible_observers.to_a).to include(user)
    expect(procurement.proposal.eligible_observers.to_a).to_not include(procurement.observers)
  end

  describe "#purchase_type" do
    it "associates 0 with software" do
      procurement = build(:gsa18f_procurement, purchase_type: 0)

      expect(procurement.purchase_type).to eq "Software"
    end

    it "associates 1 with training or event" do
      procurement = build(:gsa18f_procurement, purchase_type: 1)

      expect(procurement.purchase_type).to eq "Training/Event"
    end

    it "associates 2 with office supply or miscelleanous" do
      procurement = build(:gsa18f_procurement, purchase_type: 2)

      expect(procurement.purchase_type).to eq "Office Supply/Miscellaneous"
    end

    it "associates 3 with hardware" do
      procurement = build(:gsa18f_procurement, purchase_type: 3)

      expect(procurement.purchase_type).to eq "Hardware"
    end

    it "associates 4 with other" do
      procurement = build(:gsa18f_procurement, purchase_type: 4)

      expect(procurement.purchase_type).to eq "Other"
    end
  end

  describe "#editable?" do
    it "is true" do
      procurement = build(:gsa18f_procurement)
      expect(procurement).to be_editable
    end
  end

  describe "#total_price" do
    it "gets price from two fields" do
      procurement = build(
        :gsa18f_procurement, cost_per_unit: 18.50, quantity: 20)
      expect(procurement.total_price).to eq(18.50 * 20)
    end
  end

  describe "#public_identifier" do
    it "returns proposal id prenended with pound" do
      procurement = build(:gsa18f_procurement)
      proposal = procurement.proposal

      expect(procurement.public_identifier).to eq "##{proposal.id}"
    end
  end
end
