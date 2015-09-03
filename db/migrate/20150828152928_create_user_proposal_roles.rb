class CreateUserProposalRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name
      t.timestamps null: true
    end
    create_table :proposal_roles do |t|
      t.integer :role_id, null: false
      t.integer :user_id, null: false
      t.integer :proposal_id, null: false
      t.index [:role_id, :user_id, :proposal_id], unique: true
    end
    create_table :user_roles do |t|
      t.integer :user_id, null: false
      t.integer :role_id, null: false
      t.index [:user_id, :role_id], unique: true
    end
  end
end
