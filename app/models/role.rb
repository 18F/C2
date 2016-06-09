class Role < ActiveRecord::Base
  has_many :proposal_roles
  has_many :proposals, through: :proposal_roles
  has_many :user_roles
  has_many :users, through: :user_roles


  def self.ensure_system_roles_exist
    SYSTEM_ROLES.each { |r| Role.find_or_create_by!(name: r) }
  end
  ensure_system_roles_exist

end
