describe "header nav" do
  describe "summary link" do
    it "is displayed for gateway admin users" do
      gateway_admin_user = create(:user, :gateway_admin)
      login_as(gateway_admin_user)
      @page = HomePage.new
      @page.load
      expect(@page.header).to have_summary_link
    end

    it "is not displayed for users who are not gateway admins" do
      user = create(:user)
      login_as(user)
      @page = HomePage.new
      @page.load
      expect(@page.header).to_not have_summary_link
    end
  end
end
