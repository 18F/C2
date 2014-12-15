class CreateProposals < ActiveRecord::Migration
  def change
    create_table :proposals do |t|
      t.string :status
      t.string :flow
      t.timestamps
    end
    add_reference :carts, :proposal

    reversible do |dir|
      Cart.reset_column_information

      dir.up do
        Cart.find_each do |cart|
          cart.create_proposal!(
            status: cart.status,
            flow: cart.flow,
            created_at: cart.created_at,
            updated_at: cart.updated_at
          )
        end
      end

      dir.down do
        Proposal.find_each do |proposal|
          proposal.cart.update_attributes!(
            status: proposal.status,
            flow: proposal.flow
          )
        end
      end
    end

    remove_column :carts, :flow, :string
    remove_column :carts, :status, :string
  end
end
