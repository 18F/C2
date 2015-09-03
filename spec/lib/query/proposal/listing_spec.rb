describe Query::Proposal::Listing do
  let(:params) { ActionController::Parameters.new }
  let(:user) { FactoryGirl.create(:user) }

  [:pending, :approved, :cancelled].each do |status|
    describe "##{status}" do
      it "only returns that user's Proposals when they are an app admin" do
        FactoryGirl.create(:proposal, status: status)
        proposal = FactoryGirl.create(:proposal, requester: user, status: status)

        with_env_var('ADMIN_EMAILS', user.email_address) do
          listing = Query::Proposal::Listing.new(user, params)
          expect(listing.send(status).rows).to eq([proposal])
        end
      end

      context "with an arbitrary client" do
        before do
          user.update_attribute(:client_slug, 'ncr')
        end

        it "only displays that user's Proposals when they are a client admin" do
          proposal = FactoryGirl.create(:proposal, requester: user, status: status)

          other_proposal = FactoryGirl.create(:proposal, status: status)
          FactoryGirl.create(:ncr_work_order, proposal: other_proposal)

          with_env_var('CLIENT_ADMIN_EMAILS', user.email_address) do
            listing = Query::Proposal::Listing.new(user, params)
            expect(listing.send(status).rows).to eq([proposal])
          end
        end
      end
    end
  end
end
