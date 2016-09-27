class AddGsa18fSupervisorRole < ActiveRecord::Migration
  def up
    unless Role.find_by(name: "gsa18f_supervisor")
      role = Role.create(name: "gsa18f_supervisor")
      role.save!
    end
  end

  def down
    User.joins(:roles).where("roles.name = ?", "gsa18f_supervisor").each do |user|
      user.remove_role("gsa18f_supervisor")
    end
    Role.where(name: "beta_feature_list").destroy_all
  end
end
