class CreateUploadInspiration < ActiveRecord::Migration
  def self.up
    create_table :upload_inspirations do |t|
      t.integer :conversation, :null => false, :dependent => :delete
      t.string :inspiration_file_name, :inspiration_content_type
      t.integer :inspiration_file_size
      t.datetime :inspiration_updated_at
      t.timestamps
    end
  end
end
