class AddClientDataToProposals < ActiveRecord::Migration
  def change
    add_reference :proposals, :clientdata, polymorphic: true, index: true
  end
end
