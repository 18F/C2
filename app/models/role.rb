class Role < ActiveRecord::Base
  has_many :proposal_roles
  has_many :proposals, through: :proposal_roles
  has_many :user_roles
  has_many :users, through: :user_roles

  # Safely ensure that the system roles in `config/initializers/01_c2.rb`
  # exist in the database. Rails will run this code when it loads the
  # `Role` class at bootup.
  def self.ensure_system_roles_exist
    SYSTEM_ROLES.each { |r| Role.find_or_create_by!(name: r) }
  end

  ensure_system_roles_exist if connected? && connection.table_exists?("roles")
end
