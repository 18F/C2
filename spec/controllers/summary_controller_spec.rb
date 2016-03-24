describe SummaryController do
  describe "#index" do
    describe "authorize" do
      it "blocks non-admins" do
        user = create(:user)
        login_as(user)
        get :index
        expect(response.status).to eq(403)
      end

      it "requires client_slug if the user is a client admin" do
        admin_user = create(:user, :client_admin)
        login_as(admin_user)
        get :index
        expect(response.status).to eq(403)
      end

      it "requires admin or client_admin or gateway_admin role" do
        admin_user = create(:user, :admin)
        login_as(admin_user)
        get :index
        expect(response.status).to eq(200)

        client_admin_user = create(:user, :client_admin, client_slug: "ncr")
        login_as(client_admin_user)
        get :index
        expect(response.status).to eq(200)

        gateway_admin_user = create(:user, :gateway_admin)
        login_as(gateway_admin_user)
        get :index
        expect(response.status).to eq(200)
      end
    end

    it "takes optional fiscal year" do
      admin_user = create(:user, :admin, client_slug: "ncr")
      login_as(admin_user)
      get :index, fiscal_year: 2015
      expect(response.status).to eq(200)
    end

    describe "summaries" do
      context "when the user is a regular admin" do
        it "produces a summary for each client" do
          gateway_admin_user = create(:user, :admin)
          login_as(gateway_admin_user)
          get :index
          expect(assigns(:summaries).map(&:client_namespace).sort).to eq(Proposal.client_slugs.sort.map(&:titleize))
        end
      end

      context "when the user is a gateway admin" do
        it "produces a summary for each client" do
          gateway_admin_user = create(:user, :gateway_admin)
          login_as(gateway_admin_user)
          get :index
          expect(assigns(:summaries).map(&:client_namespace).sort).to eq(Proposal.client_slugs.sort.map(&:titleize))
        end
      end

      context "when the user is a client admin" do
        it "produces a single summary" do
          client_admin_user = create(:user, :client_admin, client_slug: "ncr")
          login_as(client_admin_user)
          get :index
          expect(assigns(:summaries).length).to eq(1)
          expect(assigns(:summaries)[0].client_namespace).to eq(client_admin_user.client_slug.titleize)
        end

        context "and the user is also a regular or gateway admin" do
          it "produces a summary for each client" do
            client_admin_user = create(:user, :client_admin, client_slug: "ncr")
            client_admin_user.add_role(:gateway_admin)
            login_as(client_admin_user)
            get :index
            expect(assigns(:summaries).map(&:client_namespace).sort).to eq(Proposal.client_slugs.sort.map(&:titleize))
          end
        end
      end
    end
  end
end
