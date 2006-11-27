class M3 < ActiveRecord::Migration
  
  def self.up
    add_index :groups, :name
    add_index :groups, :created_at
  
    add_index :haiku_comments, :haiku_id
    add_index :haiku_comments, :user_id
    add_index :haiku_comments, :created_at
    
    add_index :haikus, :user_id
    add_index :haikus, :created_at
    
    add_index :haiku_tags, [:tag_id, :haiku_id], :unique => true
    add_index :haiku_tags, :haiku_id
  
    add_index :tags, :name, :unique => true
    
    add_index :users, :username, :unique => true
    
    add_index :user_haiku_favorites, [:user_id, :haiku_id], :unique => true
    add_index :user_haiku_favorites, :haiku_id
  end

  def self.down
  end
end