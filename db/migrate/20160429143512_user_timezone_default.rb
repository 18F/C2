class UserTimezoneDefault < ActiveRecord::Migration
  def up
    execute "ALTER TABLE users ALTER timezone SET DEFAULT 'Eastern Time (US & Canada)'"
    execute "UPDATE users SET timezone='Eastern Time (US & Canada)' WHERE timezone = 'UTC'"
  end

  def down
    execute "ALTER TABLE users ALTER timezone SET DEFAULT 'UTC'"
  end
end
