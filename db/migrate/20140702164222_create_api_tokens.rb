class CreateApiTokens < ActiveRecord::Migration
  def change
    create_table :api_tokens do |t|
      t.string :access_token
      t.integer :user_id
      t.integer :cart_id
      t.datetime :expires_at

      t.timestamps
    end
  end
end
