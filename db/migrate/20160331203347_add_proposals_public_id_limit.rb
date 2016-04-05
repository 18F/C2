class AddProposalsPublicIdLimit < ActiveRecord::Migration
  def up
    execute "alter table proposals alter column public_id type varchar(255)"
  end

  def down
    execute "alter table proposals alter column public_id type varchar(255)"
  end
end
