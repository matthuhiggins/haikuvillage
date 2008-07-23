class AddInspirations < ActiveRecord::Migration
  def self.up
    change_table :conversations do |t|
      t.string :inspiration_type, :null => true
    end
    
    add_index :conversations, :inspiration_type
    
    create_table :flickr_inspirations do |t|
      t.integer :conversation_id, :null => true
      t.integer :farm_id, :server_id, :photo_id, :null => false
      t.string :secret, :null => false
      t.timestamps
    end
    
    create_table :youtube_inspiration do |t|
      t.string :video_id, :null => false
    end
  end
end