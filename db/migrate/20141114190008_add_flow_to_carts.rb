class AddFlowToCarts < ActiveRecord::Migration
  def change
    add_column :carts, :flow, :string
  end
end
