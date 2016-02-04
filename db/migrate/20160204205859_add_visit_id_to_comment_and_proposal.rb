class AddVisitIdToCommentAndProposal < ActiveRecord::Migration
  def up
    add_column :proposals, :visit_id, :integer
    add_column :comments, :visit_id, :integer
  end

  def down
    drop_column :proposals, :visit_id
    drop_column :comments, :visit_id
  end
end
