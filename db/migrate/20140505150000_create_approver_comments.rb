class CreateApproverComments < ActiveRecord::Migration
  def change
    create_table :approver_comments do |t|
      t.text :comment_text
      t.integer :approver_id

      t.timestamps
    end
  end
end
