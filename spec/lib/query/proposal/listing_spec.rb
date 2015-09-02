describe Query::Proposal::Listing do
  let(:params) { ActionController::Parameters.new }
  let(:user) { FactoryGirl.create(:user) }
  let(:another_user) { FactoryGirl.create(:user) }
  let(:yet_another_user) { FactoryGirl.create(:user) }

  [:pending, :approved, :cancelled].each do |status|
    describe "##{status}" do
      it "only returns that user's Proposals when they are an app admin" do
        FactoryGirl.create(:proposal, status: status)
        proposal = FactoryGirl.create(:proposal, requester: user, status: status)

        listing = Query::Proposal::Listing.new(user, params)
        expect(listing.send(status).rows).to eq([proposal])
      end

      context "with an arbitrary client" do
        before do
          user.update_attribute(:client_slug, 'ncr')
          another_user.update_attribute(:client_slug, 'ncr')
          yet_another_user.update_attribute(:client_slug, 'gsa18f')
        end

        describe "when user is not an admin of any kind" do
          it "only displays that user's Proposals" do
            proposal = FactoryGirl.create(:proposal, requester: user, status: status)
            other_proposal = FactoryGirl.create(:proposal, requester: another_user, status: status)
            FactoryGirl.create(:ncr_work_order, proposal: other_proposal)
  
            listing = Query::Proposal::Listing.new(user, params)
            expect(listing.send(status).rows).to eq([proposal])
          end
        end

        describe "when user is a client_admin" do
          before do
            user.add_role('client_admin')
          end

          xit "user can see all proposals within their client scope" do
            proposal = FactoryGirl.create(:proposal, requester: user, status: status)
            other_proposal = FactoryGirl.create(:proposal, requester: another_user, status: status)
            FactoryGirl.create(:ncr_work_order, proposal: other_proposal)
  
            listing = Query::Proposal::Listing.new(user, params)
            expect(listing.send(status).rows).to eq([proposal, other_proposal])
          end

          xit "user cannot see proposals outside their client scope" do
            proposal = FactoryGirl.create(:proposal, requester: user, status: status)
            other_proposal = FactoryGirl.create(:proposal, requester: yet_another_user, status: status)
            FactoryGirl.create(:ncr_work_order, proposal: other_proposal)
  
            listing = Query::Proposal::Listing.new(user, params)
            expect(listing.send(status).rows).to eq([proposal])
          end
        end

        describe "when user is an admin" do
          before do
            user.add_role('admin')
          end

          xit "user can see all proposals regardless of client scope" do
            proposal = FactoryGirl.create(:proposal, requester: user, status: status)
            other_proposal = FactoryGirl.create(:proposal, requester: another_user, status: status)
            yet_another_proposal = FactoryGirl.create(:proposal, requester: yet_another_user, status: status)
            FactoryGirl.create(:ncr_work_order, proposal: other_proposal)
  
            listing = Query::Proposal::Listing.new(user, params)
            expect(listing.send(status).rows).to eq([proposal, other_proposal, yet_another_proposal])
          end 
        end

      end
    end
  end
end
