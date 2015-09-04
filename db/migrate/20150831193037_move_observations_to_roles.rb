class MoveObservationsToRoles < ActiveRecord::Migration

  def change
    role = Role.find_or_create_by(name: 'observer')

    # We have to use raw sql because we've subclassed the observation class
    pgres = ProposalRole.connection.execute("SELECT DISTINCT(proposal_id, user_id) FROM observations WHERE user_id IN (SELECT id FROM users)")
    pgres.each_row do |row|
      prole = ProposalRole.create(proposal_id: row.first, user_id: row.second, role_id: role.id)
    end

    drop_table :observations

  end
end
