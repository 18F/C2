describe ClientDataHelper do
  describe "#modify_client_data_button" do
    it "returns edit path for a client data type with edit path" do
      work_order = create(:ncr_work_order)
      proposal = work_order.proposal

      expect(modify_client_data_button(proposal)).to eq(
        link_to(
          "Modify Request",
          edit_ncr_work_order_path(work_order),
          class: "form-button modify"
        )
      )
    end

    it "returns empty string if proposal has no client data" do
      proposal = build(:proposal, client_data: nil)

      expect(modify_client_data_button(proposal)).to eq ""
    end

    it "returns empty string if client data is not editable" do
      client_data = double(editable?: false)
      proposal = create(:proposal)
      allow(proposal).to receive(:client_data).and_return(client_data)

      expect(modify_client_data_button(proposal)).to eq ""
    end
  end
end
