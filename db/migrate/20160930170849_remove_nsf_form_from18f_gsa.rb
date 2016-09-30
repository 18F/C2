class RemoveNsfFormFrom18fGsa < ActiveRecord::Migration
  def change
    remove_column :gsa18f_events, :nfs_form
  end
end
