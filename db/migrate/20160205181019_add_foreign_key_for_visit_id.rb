class AddForeignKeyForVisitId < ActiveRecord::Migration
  def up
    add_foreign_key :proposals, :visits
    add_foreign_key :comments, :visits
  end
  def down
    remove_foreign_key :proposals, :visits
    remove_foreign_key :comments, :visits
  end
end
