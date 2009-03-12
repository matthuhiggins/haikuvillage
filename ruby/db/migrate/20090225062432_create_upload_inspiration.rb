class CreateUploadInspiration < ActiveRecord::Migration
  def self.up
    create_table :upload_inspirations do |t|
      t.integer :conversation_id, :null => false
      t.string :inspiration_file_name, :inspiration_content_type
      t.integer :inspiration_file_size
      t.datetime :inspiration_updated_at
      t.timestamps
    end

    add_foreign_key :upload_inspirations, :conversation_id, :conversations, :dependent => :delete
  end

  def self.down
  end
end
