class AddDbConstraints < ActiveRecord::Migration
  def up
    # some dirty data we must clean up before we add constraint
    execute "DELETE FROM approvals WHERE proposal_id NOT IN (SELECT id FROM proposals)"
    execute "DELETE FROM comments WHERE proposal_id NOT IN (SELECT id FROM proposals)"

    execute "ALTER TABLE approval_delegates ADD CONSTRAINT assigner_id_fkey FOREIGN KEY (assigner_id) REFERENCES users (id)"
    execute "ALTER TABLE approval_delegates ADD CONSTRAINT assignee_id_fkey FOREIGN KEY (assignee_id) REFERENCES users (id)"
    execute "ALTER TABLE approvals ADD CONSTRAINT parent_id_fkey FOREIGN KEY (parent_id) REFERENCES approvals (id)"
    execute "ALTER TABLE approvals ADD CONSTRAINT user_id_fkey FOREIGN KEY (user_id) REFERENCES users (id)"
    execute "ALTER TABLE approvals ADD CONSTRAINT proposal_id_fkey FOREIGN KEY (proposal_id) REFERENCES proposals (id)"
    execute "CREATE UNIQUE INDEX approvals_user_proposal_idx ON approvals USING btree (user_id, proposal_id)"
    execute "ALTER TABLE attachments ADD CONSTRAINT user_id_fkey FOREIGN KEY (user_id) REFERENCES users (id)"
    execute "ALTER TABLE attachments ADD CONSTRAINT proposal_id_fkey FOREIGN KEY (proposal_id) REFERENCES proposals (id)"
    execute "ALTER TABLE comments ADD CONSTRAINT user_id_fkey FOREIGN KEY (user_id) REFERENCES users (id)"
    execute "ALTER TABLE comments ADD CONSTRAINT proposal_id_fkey FOREIGN KEY (proposal_id) REFERENCES proposals (id)"
    execute "ALTER TABLE proposal_roles ADD CONSTRAINT user_id_fkey FOREIGN KEY (user_id) REFERENCES users (id)"
    execute "ALTER TABLE proposal_roles ADD CONSTRAINT proposal_id_fkey FOREIGN KEY (proposal_id) REFERENCES proposals (id)"
    execute "ALTER TABLE proposal_roles ADD CONSTRAINT role_id_fkey FOREIGN KEY (role_id) REFERENCES roles (id)"
    execute "ALTER TABLE proposals ADD CONSTRAINT requester_id_fkey FOREIGN KEY (requester_id) REFERENCES users (id)"
    execute "CREATE UNIQUE INDEX roles_name_idx ON roles USING btree (name)"
    execute "ALTER TABLE user_roles ADD CONSTRAINT user_id_fkey FOREIGN KEY (user_id) REFERENCES users (id)"
    execute "ALTER TABLE user_roles ADD CONSTRAINT role_id_fkey FOREIGN KEY (role_id) REFERENCES roles (id)"
  end

  def down
    execute "ALTER TABLE approval_delegates DROP CONSTRAINT assigner_id_fkey"
    execute "ALTER TABLE approval_delegates DROP CONSTRAINT assignee_id_fkey"
    execute "ALTER TABLE approvals DROP CONSTRAINT parent_id_fkey"
    execute "ALTER TABLE approvals DROP CONSTRAINT user_id_fkey"
    execute "ALTER TABLE approvals DROP CONSTRAINT proposal_id_fkey"
    execute "DROP INDEX approvals_user_proposal_idx"
    execute "ALTER TABLE attachments DROP CONSTRAINT user_id_fkey"
    execute "ALTER TABLE attachments DROP CONSTRAINT proposal_id_fkey"
    execute "ALTER TABLE comments DROP CONSTRAINT user_id_fkey"
    execute "ALTER TABLE comments DROP CONSTRAINT proposal_id_fkey"
    execute "ALTER TABLE proposal_roles DROP CONSTRAINT user_id_fkey"
    execute "ALTER TABLE proposal_roles DROP CONSTRAINT proposal_id_fkey"
    execute "ALTER TABLE proposal_roles DROP CONSTRAINT role_id_fkey"
    execute "DROP INDEX roles_name_idx"
    execute "ALTER TABLE user_roles DROP CONSTRAINT user_id_fkey"
    execute "ALTER TABLE user_roles DROP CONSTRAINT role_id_fkey"
  end
end
