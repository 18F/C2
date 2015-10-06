class DropCarts < ActiveRecord::Migration
  def change
    execute "DROP TABLE carts"
  end
end
