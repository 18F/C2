class AddPositionToApprovals < ActiveRecord::Migration
  def change
    add_column :approvals, :position, :integer
  end
end
