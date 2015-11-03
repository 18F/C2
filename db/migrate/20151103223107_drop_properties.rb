class DropProperties < ActiveRecord::Migration
  def change
    drop_table :properties
  end
end
