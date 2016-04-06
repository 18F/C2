class FixVersionsItemTypeForSteps < ActiveRecord::Migration
  def up
    execute "UPDATE versions SET item_type = 'Steps::Approval' WHERE item_type = 'Approval'"
  end

  def down
    execute "UPDATE versions SET item_type = 'Approval' WHERE item_type = 'Steps::Approval'"
  end
end
