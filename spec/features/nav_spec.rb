describe "header nav" do
  describe "summary link" do
    context "if the user is an admin of some kind" do
      it "is displayed", :js do
        admin_user = create(:user, :admin)
        login_as(admin_user)
        @page = HomePage.new
        @page.load
        expect(@page.header).to have_summary_link
      end
    end

    context "if the user is not an admin of some kind" do
      it "is not displayed" do
        user = create(:user)
        login_as(user)
        @page = HomePage.new
        @page.load
        expect(@page.header).to_not have_summary_link
      end
    end
  end
end
