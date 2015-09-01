class MoveClientAdminRole < ActiveRecord::Migration
  def change
    role = Role.find_or_create_by(name: 'client_admin')

    User.client_admin_emails.each do |email_address|
      user = User.find_by_email_address(email_address)
      user.add_role(role)
      user.save!
    end
  end
end
