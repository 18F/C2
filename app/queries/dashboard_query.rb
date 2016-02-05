class DashboardQuery
  def initialize(user)
    @user = user
  end

  private

  attr_reader :user
end
