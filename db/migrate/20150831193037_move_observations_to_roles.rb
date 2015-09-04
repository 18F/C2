class MoveObservationsToRoles < ActiveRecord::Migration

  def change
    role = Role.find_or_create_by(name: 'observer')

    # We have to use raw sql because we've subclassed the observation class
    pgres = ProposalRole.connection.execute("SELECT proposal_id, user_id from observations")
    seen_proles = {}
    pgres.each_row do |row|
      # if we have no user (dangling FK) then skip it
      user = User.find(row.second) or next

      # track to avoid duplicates
      k = [row.first.to_s, row.second.to_s, role.id.to_s].join(';')
      next if seen_proles[k]

      # create new record, marking it as done afterwards
      prole = ProposalRole.create(proposal_id: row.first, user_id: row.second, role_id: role.id)
      seen_proles[k] = true
    end

    drop_table :observations

  end
end
