class Indexes < ActiveRecord::Migration
  
  def self.up
    add_index :haiku_comments, [:haiku_id, :created_at]
    add_index :haiku_comments, [:user_id, :created_at]
    
    add_index :haikus, :user_id
    add_index :haikus, :created_at

    add_index :haiku_favorites, [:user_id, :haiku_id], :unique => true
    add_index :haiku_favorites, [:haiku_id, :user_id, :created_at]
    add_index :haiku_favorites, [:created_at, :haiku_id]

    add_index :haiku_tags, [:tag_id, :haiku_id], :unique => true
    add_index :haiku_tags, [:haiku_id, :tag_id]
    add_index :haiku_tags, [:created_at, :tag_id]

    add_index :schools, :name, :unique => true
    add_index :schools, :created_at

    add_index :school_haikus, [:school_id, :haiku_id], :unique => true
    add_index :school_haikus, [:haiku_id, :school_id]
    
    add_index :school_users, [:school_id, :user_id], :unique => true
    add_index :school_users, [:user_id, :school_id]  

    add_index :tags, :name, :unique => true
    add_index :tags, :haiku_tags_count
    add_index :tags, :created_at
    
    add_index :users, :username, :unique => true
  end

  def self.down
  end
end