describe ProposalsController do
  include ReturnToHelper
  
  let(:user) { create(:user, client_slug: "test") }

  describe '#index' do
    before do
      login_as(user)
    end

    it "sets data fields" do
      proposal1 = create(:proposal, requester: user)
      proposal2 = create(:proposal, :with_approver, approver_user: user)

      get :index
      expect(assigns(:pending_review_data).rows.sort).to eq [proposal2]
      expect(assigns(:pending_data).rows.sort).to eq [proposal1]
      expect(assigns(:completed_data).rows.sort).to be_empty
      expect(assigns(:canceled_data).rows.sort).to be_empty
    end
  end

  describe '#archive' do
    it "redirects to query by status" do
      login_as(user)
      get :archive
      expect(response).to redirect_to(query_proposals_url(text: "status:completed"))
    end
  end

  describe '#show' do
    before do
      login_as(user)
    end

    context "visitors" do
      it "should allow the requester to see it" do
        proposal = create(:proposal, requester: user)
        get :show, id: proposal.id
        expect(response.status).to eq(200)
        expect(response).not_to redirect_to("/proposals/")
        expect(flash[:alert]).not_to be_present
      end

      it "treats non-subscriber users as un-authorized" do
        proposal = create(:proposal)
        get :show, id: proposal.id
        expect(response.status).to eq(403)
      end
    end

    context "admins" do
      let(:requester) { create(:user) }
      let(:proposal) { create(:proposal, requester_id: requester.id, client_data_type: "SomeCompany::SomethingApprovable") }

      before do
        allow(Proposal).to receive(:client_model_names).and_return(["SomeCompany::SomethingApprovable"])
        allow(Proposal).to receive(:client_slugs).and_return(%w(some_company some_other_company ncr))
      end

      it "allows admins to view requests of same client" do
        user.add_role("client_admin")
        user.update_attributes!(client_slug: "some_company")

        get :show, id: proposal.id
        expect(response).not_to redirect_to(proposals_path)
        expect(response.request.fullpath).to eq(proposal_path(proposal.id))
      end

      it "allows app admins to view requests outside of related client" do
        user.update_attributes!(client_slug: "some_other_company")
        user.add_role("admin")

        get :show, id: proposal.id
        expect(response).not_to redirect_to(proposals_path)
        expect(response.request.fullpath).to eq(proposal_path(proposal.id))
      end
    end
  end

  describe '#show + new details' do
    context "cookie triggered view" do
      it "should render the show_next view" do
        setup_proposal_page
        expect(response.status).to eq(200)
        expect(response).to render_template("show_next")
        expect(response).to_not render_template("show")
      end
    end
  end

  describe '#query', elasticsearch: true do
    let!(:proposal) { create(:proposal, requester: user) }
    before do
      login_as(user)
    end

    it "requires valid search params" do
      get :query
      expect(response).to redirect_to(proposals_path)
      expect(flash[:alert]).to_not be_nil
    end

    it "should filter results by date range" do
      prev_zone = Time.zone
      Time.zone = "UTC"
      past_proposal = create(
        :proposal, created_at: Time.zone.local(2012, 5, 6), requester: user
      )
      get :query
      expect(assigns(:proposals_data).rows).to eq([proposal, past_proposal])

      get :query, start_date: "2012-05-04", end_date: "2012-05-07"
      expect(assigns(:proposals_data).rows).to eq([past_proposal])

      get :query, start_date: "2012-05-04", end_date: "2012-05-06"
      expect(assigns(:proposals_data).rows).to eq([])
      Time.zone = prev_zone
    end

    it "filters results by proposal status" do
      get :query, status: "pending"
      expect(assigns(:proposals_data).rows).to eq([proposal])

      get :query, status: "canceled"
      expect(assigns(:proposals_data).rows).to eq([])
    end

    it "ignores bad input" do
      get :query, start_date: "dasdas"
      expect(assigns(:proposals_data).rows).to eq([proposal])
    end

    context "#datespan_header" do
      render_views

      it "has a nice header for month spans" do
        get :query, start_date: "2012-05-01", end_date: "2012-06-01"
        expect(response.body).to include("May 2012")
      end

      it "has a generic header for other dates" do
        get :query, start_date: "2012-05-02", end_date: "2012-06-02"
        expect(response.body).to include("2012-05-02 - 2012-06-02")
      end
    end

    context "search" do
      it "plays nicely with TabularData" do
        anon_user = create(:user)
        login_as(anon_user)
        double, single, triple = Array.new(3) { create(:proposal, requester: anon_user) }
        double.update(public_id: "AAA AAA")
        single.update(public_id: "AAA")
        triple.update(public_id: "AAA AAA AAA")

        double.reindex
        single.reindex
        triple.reindex

        Proposal.__elasticsearch__.refresh_index!

        es_execute_with_retries 3 do
          get :query, text: "AAA"
          query = assigns(:proposals_data).rows

          expect(query.length).to be(3)
          expect(query[0].id).to be(triple.id)
          expect(query[1].id).to be(double.id)
          expect(query[2].id).to be(single.id)
        end
      end

      it "returns JSON for preview count" do
        login_as(user)
        Array.new(3) do |i|
          wo = create(:test_client_request, project_title: "Work Order #{i}", requester: user)
          wo.proposal.reindex
        end
        Proposal.__elasticsearch__.refresh_index!

        es_execute_with_retries 3 do
          get :query_count, text: "work order"
          expect(response.status).to eq 200
          expect(response.headers["Content-Type"]).to include "application/json"
          expect(response.body).to eq({ total: 3 }.to_json)
        end
      end

      it "returns valid JSON for preview count error" do
        login_as(user)

        es_execute_with_retries 3 do
          get :query_count
          expect(response.status).to eq 200
          expect(response.headers["Content-Type"]).to include "application/json"
          expect(response.body).to eq({ total: 0 }.to_json)
        end
      end
    end
  end

  describe "#download", elasticsearch: true do
    render_views

    it "downloads results as CSV" do
      login_as(user)
      proposals = Array.new(30) do |i|
        wo = create(:test_client_request, project_title: "Work Order #{i}")
        wo.proposal.update(requester: user)
        wo.proposal.reindex
        wo.proposal
      end
      Proposal.__elasticsearch__.refresh_index!

      es_execute_with_retries 3 do
        get :download, text: "Work Order", format: "csv"
        expect(response.body).to include "Work Order 29"
        expect(response.body).to include proposals.last.client_data.approving_official.display_name
        expect(response.headers["Content-Type"]).to eq "text/csv"
        expect(response.body).not_to include("\n\n")
      end
    end
  end

  describe '#cancel_form' do
    let(:proposal) { create(:proposal) }

    it "should allow the requester to see it" do
      login_as(user)
      proposal.update_attributes(requester_id: user.id)

      get :show, id: proposal.id
      expect(response).not_to redirect_to("/proposals/")
      expect(flash[:alert]).not_to be_present
    end

    it "should redirect random users" do
      login_as(user)
      get :cancel_form, id: proposal.id
      expect(response).to redirect_to(proposal_path)
      expect(flash[:alert]).to eq "You are not the requester"
    end

    it "should redirect for canceled requests" do
      proposal.update(status: "canceled")
      login_as(proposal.requester)

      get :cancel_form, id: proposal.id

      expect(response).to redirect_to(proposal_path(proposal.id))
      expect(flash[:alert]).to match(/has been canceled/)
    end
  end

  describe "#cancel" do
    let!(:proposal) { create(:proposal, requester: user) }

    before do
      login_as(user)
    end

    it "sends a cancelation email" do
      mock_dispatcher = double("dispatcher").as_null_object
      allow(DispatchFinder).to receive(:run).with(proposal).and_return(mock_dispatcher)
      expect(mock_dispatcher).to receive(:deliver_cancelation_emails)

      post :cancel, id: proposal.id, reason_input: "My test cancelation text"
    end
  end

  describe "#complete" do
    it "signs the user in via the token" do
      proposal = create(:proposal, :with_approver)
      approval = proposal.individual_steps.first
      token = create(:api_token, step: approval)

      get :complete, id: proposal.id, cch: token.access_token

      expect(controller.send(:current_user)).to eq(approval.user)
    end

    it "won't sign the user in via the token if delegated" do
      proposal = create(:proposal, :with_approver)
      approval = proposal.individual_steps.first
      token = create(:api_token, step: approval)
      approval.user.add_delegate(create(:user))

      get :complete, id: proposal.id, cch: token.access_token

      expect(response).to redirect_to(root_path(return_to: make_return_to("Previous", request.fullpath)))
    end

    it "won't allow a missing token when using GET" do
      proposal = create(:proposal, :with_approver)
      login_as(proposal.approvers.first)

      get :complete, id: proposal.id

      expect(response).to have_http_status(403)
    end

    it "will allow action if the token is valid" do
      proposal = create(:proposal, :with_approver)
      approval = proposal.individual_steps.first
      token = create(:api_token, step: approval)

      get :complete, id: proposal.id, cch: token.access_token

      approval.reload
      expect(approval).to be_completed
    end

    it "doesn't allow a token to be reused" do
      proposal = create(:proposal, :with_approver)
      approval = proposal.individual_steps.first
      token = create(:api_token, step: approval)
      token.use!

      get :complete, id: proposal.id, cch: token.access_token

      expect(flash[:alert]).to include(I18n.t("errors.policies.api_token.not_delegate"))
    end

    it "won't allow the approval to be completed twice through the web ui" do
      proposal = create(:proposal, :with_approver)
      login_as(proposal.approvers.first)

      post :complete, id: proposal.id

      expect(proposal.reload).to be_completed
      expect(flash[:success]).not_to be_nil
      expect(flash[:alert]).to be_nil

      flash.clear
      post :complete, id: proposal.id

      expect(response).to redirect_to(proposal_path(proposal))
      expect(flash[:error]).to eq I18n.t("errors.policies.proposal.step_complete")
    end

    it "won't allow different delegates to approve" do
      proposal = create(:proposal, :with_approver)
      delegate1 = create(:user)
      delegate2 = create(:user)
      mailbox = proposal.approvers.first
      mailbox.add_delegate(delegate1)
      mailbox.add_delegate(delegate2)
      login_as(delegate1)

      post :complete, id: proposal.id

      expect(flash[:success]).not_to be_nil
      expect(flash[:alert]).to be_nil

      flash.clear
      login_as(delegate2)
      post :complete, id: proposal.id

      expect(response).to redirect_to(proposal_path(proposal))
      expect(flash[:error]).to eq I18n.t("errors.policies.proposal.step_complete")
    end

    it "allows a delegate to approve via the web UI" do
      proposal = create(:proposal, :with_serial_approvers)
      mailbox = proposal.approvers.second
      delegate = create(:user)
      mailbox.add_delegate(delegate)
      proposal.individual_steps.first.complete!
      login_as(delegate)

      post :complete, id: proposal.id

      expect(flash[:success]).not_to be_nil
      expect(flash[:alert]).to be_nil
      expect(proposal.reload).to be_completed
    end
  end

  def setup_proposal_page
    login_as(user)
    user.add_role(ROLE_BETA_USER)
    user.add_role(ROLE_BETA_ACTIVE)
    @proposal = create(:proposal, requester: user)
    get :show, id: @proposal.id
  end
end
