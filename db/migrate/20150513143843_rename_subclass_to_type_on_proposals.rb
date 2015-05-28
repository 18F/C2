class RenameSubclassToTypeOnProposals < ActiveRecord::Migration
  def change
    rename_column :proposals, :subclass, :type
  end
end
