class AddReasonToObservation < ActiveRecord::Migration
  def change
    add_column :proposal_roles, :comment, :string
    add_column :proposal_roles, :created_at, :datetime
    add_column :proposal_roles, :updated_at, :datetime
  end
end
