class RemoveBetaFlagRoles < ActiveRecord::Migration
  def up
    User.joins(:roles).where("roles.name = ? or roles.name = ?", "beta_detail", "beta_feature_list").each do |user|
      unless user.in_beta_program?
        user.add_role("beta_user")
      end
      user.remove_role("beta_feature_list")
      user.remove_role("beta_detail")
    end
    Role.where(name: "beta_feature_list").destroy_all
    Role.where(name: "beta_detail").destroy_all
  end

  def down
    Role.create(name: "beta_feature_list")
    Role.create(name: "beta_detail")
    User.joins(:roles).where("roles.name = ?", "beta_user").each do |user|
      user.add_role("beta_detail")
      user.add_role("beta_feature_list")
    end
  end
end
