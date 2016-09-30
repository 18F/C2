class RemoveNsfFormFrom18fGsa < ActiveRecord::Migration
  def change
    drop_column :gsa18f_trainings, :nfs_form
  end
end
