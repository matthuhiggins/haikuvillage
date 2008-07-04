class AddInspirations < ActiveRecord::Migration
  def self.up
    change_table :conversations do |t|
      t.string :inspiration_name, :null => true
    end
    
    add_index :conversations, :inspiration_name
    
    create_table :flickr_inspiration do |t|
      t.integer :conversation_id, :null => false
      t.integer :farm_id, :server_id, :photo_id, :secret_id, :null => false
      t.timestamps
    end
    
    create_table :youtube_inspiration do |t|
      t.string :video_id, :null => false
    end
  end
end
