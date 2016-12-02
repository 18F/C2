describe ClientHelper do
  describe "#client_specific_partial" do
    context "user does not have a client slug" do
      it "returns the shared partial" do
        user = create(:user, client_slug: nil)

        partial = client_specific_partial(user, "header_links")

        expect(partial).to eq "shared/header_links"
      end
    end

    context "user has a client slug without a partial" do
      it "returns the shared partial" do
        expect(Proposal).to receive(:client_slugs).and_return(["blah blah"])
        user = create(:user, client_slug: "blah blah")

        partial = client_specific_partial(user, "header_links")

        expect(partial).to eq "shared/header_links"
      end
    end

    context "user has a client slug with a partial" do
      it "returns the appropriate partial" do
        user = create(:user, client_slug: "ncr")

        partial = client_specific_partial(user, "header_links")

        expect(partial).to eq "ncr/header_links"

      end
    end
  end

  describe "#modify_client_button" do

    it "returns empty string if proposal has no client data" do
      proposal = build(:proposal, client_data: nil)

      expect(modify_client_button(proposal)).to eq ""
    end

    it "returns empty string if client data is not editable" do
      client_data = double(editable?: false)
      proposal = create(:proposal)
      allow(proposal).to receive(:client_data).and_return(client_data)

      expect(modify_client_button(proposal)).to eq ""
    end

    it "returns empty string if proposal is canceled" do
      work_order = create(:ncr_work_order)
      proposal = work_order.proposal
      proposal.cancel!

      expect(modify_client_button(proposal)).to eq ""
    end
  end
end
