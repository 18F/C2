class AddPublicIdToProposals < ActiveRecord::Migration     
  def up
    add_column :proposals, :public_id, :string
    execute <<-SQL
      UPDATE proposals
        SET public_id = '#' || id;
    SQL
    execute <<-SQL
      UPDATE proposals
        SET public_id = 'FY15-' || id
          WHERE client_data_type = 'Ncr::WorkOrder';
    SQL
  end
  def down
    remove_column :proposals, :public_id
  end
end
