class DropApproverComments < ActiveRecord::Migration
  def change
  	drop_table :approver_comments
  end
end
