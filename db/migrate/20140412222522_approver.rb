class Approver < ActiveRecord::Migration
  def change
    create_table :approvers do |t|
      t.string :email_address
      t.belongs_to :approval_group
      t.timestamps
    end
  end
end
