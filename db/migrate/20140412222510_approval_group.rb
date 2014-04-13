class ApprovalGroup < ActiveRecord::Migration
  def change
    create_table :approval_groups do |t|
      t.string :name
      t.timestamps
    end
  end
end
