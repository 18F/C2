describe DispatchFinder do
  describe ".run" do
    context "proposal for NCR" do
      it "returns a new instance of the NcrDispatcher class" do
        proposal = create(:proposal)
        allow(proposal).to receive(:client_slug).and_return("ncr")
        allow(NcrDispatcher).to receive(:new).with(proposal)

        DispatchFinder.run(proposal)

        expect(NcrDispatcher).to have_received(:new).with(proposal)
      end
    end

    context "proposal for any other org" do
      it "returns a new instance of the Dispatcher class" do
        proposal = create(:proposal)
        allow(proposal).to receive(:client_slug).and_return("anything else")
        allow(Dispatcher).to receive(:new).with(proposal)

        DispatchFinder.run(proposal)

        expect(Dispatcher).to have_received(:new).with(proposal)
      end
    end
  end
end
