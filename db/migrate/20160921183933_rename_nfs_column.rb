class RenameNfsColumn < ActiveRecord::Migration
  def change
    rename_column :gsa18f_trainings, :NFS_form, :nfs_form
  end
end
