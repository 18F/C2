class MoveAdminEnvVarToRole < ActiveRecord::Migration
  def change
    role = Role.find_or_create_by(name: 'admin')

    ENV['ADMIN_EMAILS'].to_s.split(',').each do |email_address|
      user = User.find_by_email_address(email_address) or next
      user.add_role(role)
      user.save!
    end
  end
end
