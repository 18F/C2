describe Gsa18f::ProcurementFields do
  describe '#relevant' do
    it "returns recurring fields if recurring is true" do
      fields = Gsa18f::ProcurementFields.new.relevant(true)

      expect(fields).to include(:recurring_interval)
      expect(fields).to include(:recurring_length)
    end

    it "does not return recurring fields if recurring is false" do
      fields = Gsa18f::ProcurementFields.new.relevant(false)

      expect(fields).not_to include(:recurring_interval)
      expect(fields).not_to include(:recurring_length)
    end
  end

  describe "#display" do
    it "returns relevant fields for the procurement passed in, plus total price" do
      procurement = build(:gsa18f_procurement)

      fields = Gsa18f::ProcurementFields.new(procurement).display

      expect(fields).to eq([
        ["Additional info", procurement.additional_info],
        ["Cost per unit", procurement.cost_per_unit],
        ["Date requested", procurement.date_requested],
        ["Justification", procurement.justification],
        ["Link to product", procurement.link_to_product],
        ["Office", procurement.office],
        ["Product name and description", procurement.product_name_and_description],
        ["Purchase type", procurement.purchase_type],
        ["Quantity", procurement.quantity],
        ["Urgency", procurement.urgency],
        ["Total Price", procurement.total_price]
      ])
    end
  end
end
