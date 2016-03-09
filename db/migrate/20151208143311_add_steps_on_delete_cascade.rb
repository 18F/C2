class AddStepsOnDeleteCascade < ActiveRecord::Migration
  def up
    execute "ALTER TABLE steps DROP CONSTRAINT proposal_id_fkey, ADD CONSTRAINT proposal_id_fkey FOREIGN KEY (proposal_id) REFERENCES proposals (id) ON DELETE CASCADE"
  end

  def down
    execute "ALTER TABLE steps DROP CONSTRAINT proposal_id_fkey, ADD CONSTRAINT proposal_id_fkey FOREIGN KEY (proposal_id) REFERENCES proposals (id)"
  end
end
