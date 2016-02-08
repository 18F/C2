class AddTheVisitIdToModels < ActiveRecord::Migration
  def up
    add_column :proposals, :visit_id, :uuid
    add_column :comments, :visit_id, :uuid
    add_column :reports, :visit_id, :uuid
    add_foreign_key :proposals, :visits
    add_foreign_key :comments, :visits
    add_foreign_key :reports, :visits
  end

  def down
    remove_foreign_key :proposals, :visits
    remove_foreign_key :comments, :visits
    remove_foreign_key :reports, :visits
    drop_column :proposals, :visit_id
    drop_column :comments, :visit_id
    drop_column :reports, :visit_id
  end
end
