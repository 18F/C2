class RenameApprovalDelegatesToUserDelegates < ActiveRecord::Migration
  def change
    rename_table :approval_delegates, :user_delegates
  end
end
