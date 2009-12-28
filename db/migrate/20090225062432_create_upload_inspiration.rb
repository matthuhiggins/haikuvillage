class CreateUploadInspiration < ActiveRecord::Migration
  def self.up
    create_table :upload_inspirations do |t|
      t.references :conversation, :null => false
      t.string :inspiration_file_name, :inspiration_content_type
      t.integer :inspiration_file_size
      t.timestamps
    end
    add_foreign_key :upload_inspirations, :conversations
  end
end
