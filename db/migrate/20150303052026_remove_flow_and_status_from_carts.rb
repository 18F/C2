class RemoveFlowAndStatusFromCarts < ActiveRecord::Migration
  COLUMNS = [:flow, :status]

  def up
    # since these columns were removed in on older version of the CreateProposals migration, handle both cases
    COLUMNS.each do |column|
      if column_exists?(:carts, column)
        remove_column :carts, column
      end
    end
  end

  def down
    COLUMNS.each do |column|
      add_column :carts, column, :string
    end
  end
end
