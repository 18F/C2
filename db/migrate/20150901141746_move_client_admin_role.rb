class MoveClientAdminRole < ActiveRecord::Migration
  def change
    role_name = 'client_admin'

    ENV['CLIENT_ADMIN_EMAILS'].to_s.split(',').each do |email_address|
      user = User.find_by_email_address(email_address) or next
      user.add_role(role_name)
      user.save!
    end
  end
end
