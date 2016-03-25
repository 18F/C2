describe Gsa18f::ProcurementsController do
  describe "#create" do
    it "creates a procurement with the correct attributes" do
      user = create(:user, client_slug: "gsa18f")
      login_as(user)
      procurement_params = {
        gsa18f_procurement: {
          additional_info: "more info",
          cost_per_unit: 10.0,
          date_requested: Time.current,
          justification: "I want it",
          link_to_product: "www.example.com",
          office: "San Francisco",
          product_name_and_description: "Thing I want",
          purchase_type: "Software",
          quantity: 1,
          urgency: 10,
          recurring: true,
          recurring_interval: "daily",
          recurring_length: 5
        }
      }

      expect {
        post :create, procurement_params
       }.to change { Gsa18f::Procurement.count }.from(0).to(1)

      proposal = Proposal.last
      expect(proposal.client_data).to be_recurring
    end
  end
end
