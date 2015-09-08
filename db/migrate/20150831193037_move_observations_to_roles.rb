class MoveObservationsToRoles < ActiveRecord::Migration
  def change
    role = Role.find_or_create_by(name: 'observer')

    # We have to use raw sql because we've subclassed the observation class. Also, use `GROUP_BY` to find DISTINCT pairs.
    pgres = ProposalRole.connection.execute("SELECT proposal_id, user_id FROM observations WHERE user_id IN (SELECT id FROM users) GROUP BY proposal_id, user_id")
    pgres.each do |row|
      ProposalRole.create(proposal_id: row['proposal_id'], user_id: row['user_id'], role_id: role.id)
    end

    drop_table :observations
  end
end
