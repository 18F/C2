class MoveObservationsToRoles < ActiveRecord::Migration

  def change
    role = Role.find_or_create_by(name: 'observer')

    # We have to use raw sql because we've subclassed the observation class
    pgres = ProposalRole.connection.execute("SELECT DISTINCT(proposal_id, user_id) FROM observations WHERE user_id IN (SELECT id FROM users)")
    pgres.each_row do |row|
      matches = row.first.match(/\A\((\d+),(\d+)\)\z/)
      ProposalRole.create(proposal_id: matches[1], user_id: matches[2], role_id: role.id)
    end

    drop_table :observations

  end
end
