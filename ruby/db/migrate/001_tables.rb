class Tables < ActiveRecord::Migration
  def self.up  
    create_table :haikus do |t|
      t.string :text, :null => false, :limit => 765
      t.integer :user_id, :haiku_favorites_count, :null => false, :default => 0
      t.timestamps
    end

    create_table :haiku_comments do |t|
      t.integer :haiku_id, :user_id, :null => false
      t.string :text, :null => false, :limit => 1000
      t.timestamps
    end
    
    create_table :haiku_favorites, :id => false do |t|
      t.integer :user_id, :haiku_id, :null => false
      t.timestamps
    end
    
    create_table :haiku_tags, :id => false do |t|
      t.integer :haiku_id, :tag_id, :null => false
      t.timestamps
    end
    
   create_table :groups do |t|
      t.string :name, :null => false, :limit => 100
      t.string :description, :null => false, :limit => 1000
      t.boolean :isadultonly, :isprivate, :null => false
      t.timestamps
    end
    
    create_table :group_haikus, :id => false do |t|
      t.integer :group_id, :haiku_id, :null => false
      t.timestamps
    end
    
    create_table :group_users, :id => false do |t|
      t.integer :group_id, :user_id, :null => false
      t.string :user_type, :null => false
    end

    create_table :tags do |t|
      t.string :name, :null => false, :limit => 64
      t.integer :haiku_tags_count, :null => false, :default => 0
      t.timestamps
    end    

    create_table :users do |t|
      t.string :alias, :email, :hashed_password, :salt, :null => false, :limit => 100
      t.timestamps
    end

    create_table :user_logins, :id => false do |t|
      t.integer :user_id, :null => false
      t.datetime :logindate, :null => false
    end
    
    create_table :user_users, :id => false do |t|
      t.integer :sourceuser_id, :targetuser_id, :null => false
      t.boolean :accepted, :null => false
    end
  end

  def self.down
    drop_table :groups
    drop_table :group_haikus
    drop_table :group_users
    drop_table :haikus
    drop_table :haiku_comments
    drop_table :haiku_favorites
    drop_table :haiku_tags
    drop_table :sessions
    drop_table :tags
    drop_table :users
    drop_table :user_logins
    drop_table :user_users
  end
end
