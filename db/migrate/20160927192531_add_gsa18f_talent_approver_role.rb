class AddGsa18fTalentApproverRole < ActiveRecord::Migration
  def up
    unless Role.find_by(name: "gsa18f_talent_approver")
      role = Role.create(name: "gsa18f_talent_approver")
      role.save!
    end
  end

  def down
    User.joins(:roles).where("roles.name = ?", "gsa18f_talent_approver").each do |user|
      user.remove_role("gsa18f_talent_approver")
    end
  end
end
