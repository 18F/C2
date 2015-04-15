class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.attachment :file
      t.references :proposal
      t.references :user
      t.timestamps
    end
  end
end
