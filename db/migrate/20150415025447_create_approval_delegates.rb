class CreateApprovalDelegates < ActiveRecord::Migration
  def change
    create_table :approval_delegates do |t|
      t.references :assigner
      t.references :assignee
      t.timestamps
    end
  end
end
