describe UsersController do
  include ReturnToHelper
  let(:user) { create(:user, client_slug: "test") }

  describe '#update' do
    before do
      login_as(user)
    end
    it "sets beta_active to true when a beta user isn't active" do
      setup_user
      request.env["HTTP_REFERER"] = "where_i_came_from" unless request.nil? or request.env.nil?
      patch :update, id: user.id, user: {update_beta_active: true}
      expect(user.active_beta_user?).to be true
    end
    it "sets beta_active to false when beta is active" do
      setup_user
      user.add_role(ROLE_BETA_ACTIVE)
      request.env["HTTP_REFERER"] = "where_i_came_from" unless request.nil? or request.env.nil?
      patch :update, id: user.id, user: {update_beta_active: true}
      expect(user.active_beta_user?).to be false
    end
  end
  def setup_user
    user.add_role(ROLE_BETA_USER)
  end
end