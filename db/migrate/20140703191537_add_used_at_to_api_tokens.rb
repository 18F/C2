class AddUsedAtToApiTokens < ActiveRecord::Migration
  def change
    add_column :api_tokens, :used_at, :datetime
  end
end
