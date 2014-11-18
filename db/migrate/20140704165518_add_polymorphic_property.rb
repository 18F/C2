class AddPolymorphicProperty < ActiveRecord::Migration
  def change
    create_table :properties do |t|
      t.text :property
      t.text :value
      t.integer :hasproperties_id
      t.string  :hasproperties_type
    end
  end
end
