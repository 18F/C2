class AddUniqueIndexToApiTokenAccessToken < ActiveRecord::Migration
  def change
    add_index :api_tokens, :access_token, unique: true
  end
end
