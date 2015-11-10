describe Query::Proposal::Listing do
  let(:params) { ActionController::Parameters.new }
  let(:user) { create(:user) }

  [:pending, :approved, :cancelled].each do |status|
    describe "##{status}" do
      it "ignores app admin role and only returns the user's Proposals" do
        create(:proposal, status: status)
        proposal = create(:proposal, requester: user, status: status)
        user.add_role('admin')
        listing = Query::Proposal::Listing.new(user, params)
        expect(listing.send(status).rows).to eq([proposal])
      end

      context "with an arbitrary client" do
        before do
          user.update_attribute(:client_slug, "ncr")
          user.add_role('client_admin')
        end

        it "ignores client_admin role and only displays the user's Proposals" do
          proposal = create(:proposal, requester: user, status: status)

          other_proposal = create(:proposal, status: status)
          create(:ncr_work_order, proposal: other_proposal)

          listing = Query::Proposal::Listing.new(user, params)
          expect(listing.send(status).rows).to eq([proposal])
        end
      end
    end
  end
end
