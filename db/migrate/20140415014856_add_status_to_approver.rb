class AddStatusToApprover < ActiveRecord::Migration
  def change
    add_column :approvers, :status, :string
  end
end
