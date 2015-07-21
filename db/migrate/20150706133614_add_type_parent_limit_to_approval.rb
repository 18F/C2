class AddTypeParentLimitToApproval < ActiveRecord::Migration
  def change
    add_column :approvals, :type, :string
    add_reference :approvals, :parent, references: :approvals
    add_column :approvals, :min_required, :int
  end
end
