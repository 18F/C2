class AddApprovalFields < ActiveRecord::Migration
  def change
    add_reference :approvals, :parent, references: :approvals
    add_column :approvals, :min_children_needed, :int
  end
end
