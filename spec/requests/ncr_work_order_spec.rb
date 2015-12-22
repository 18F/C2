describe 'proposals' do
  include ReturnToHelper

  describe "DISABLE_CLIENT_SLUGS" do
    with_env_var("DISABLE_CLIENT_SLUGS", "ncr") do
      it "disallows any request for disabled client_slug" do
        user = create(:user, client_slug: "ncr")
        work_order = create(:ncr_work_order, requester: user)
        endpoints = [new_ncr_work_order_path, proposal_path(work_order.proposal), proposals_path, ncr_dashboard_path]

        endpoints.each do |endpoint|
          login_as(user)
          get endpoint
          expect(response.status).to eq 403 
          expect(response.body).to match "National Capital Region"
        end 
      end 
    end 
  end
end
