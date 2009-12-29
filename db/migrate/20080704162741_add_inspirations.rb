class AddInspirations < ActiveRecord::Migration
  def self.up
    change_table :conversations do |t|
      t.string :inspiration_type, :null => true
    end
    
    add_index :conversations, :inspiration_type
    
    create_table :flickr_inspirations do |t|
      t.string :title, :null => false
      t.references :conversation, :null => false
      t.integer :photo_id, :null => false, :limit => 8
      t.integer :farm_id, :server_id, :null => false
      t.string :secret, :null => false
      t.timestamps
    end
    add_index :flickr_inspirations, :photo_id, :unique => true
    add_index :flickr_inspirations, :created_at
    add_foreign_key :flickr_inspirations, :conversations

    Conversation.all.each do |conversation|
      conversation.update_attribute(:haikus_count_total, conversation.haikus.count)
    end
  end
end