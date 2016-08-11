class RemoveBetaFeatureListRoleAgain < ActiveRecord::Migration
  def up
    User.joins(:roles).where("roles.name = ?", "beta_feature_list").each do |user|
      unless user.in_beta_program?
        user.add_role("beta_user")
      end
      user.remove_role("beta_feature_list")
    end
    Role.where(name: "beta_feature_list").destroy_all
  end

  def down
    Role.create(name: "beta_feature_list")
    User.joins(:roles).where("roles.name = ?", "beta_user").each do |user|
      user.add_role("beta_feature_list")
    end
  end
end
