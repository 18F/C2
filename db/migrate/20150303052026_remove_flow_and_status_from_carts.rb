class RemoveFlowAndStatusFromCarts < ActiveRecord::Migration
  def change
    remove_column :carts, :flow, :string
    remove_column :carts, :status, :string
  end
end
