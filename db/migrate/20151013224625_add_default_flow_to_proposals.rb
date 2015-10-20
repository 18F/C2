class AddDefaultFlowToProposals < ActiveRecord::Migration
  def up
    change_column_default :proposals, :flow, 'parallel'
  end

  def down
    change_column_default :proposals, :flow, nil
  end
end
