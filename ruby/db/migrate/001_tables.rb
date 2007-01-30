class Tables < ActiveRecord::Migration
  def self.up  
    create_table :haikus do |t|
      t.column :line1, :string, :null => false, :limit => 255
      t.column :line2, :string, :null => false, :limit => 255
      t.column :line3, :string, :null => false, :limit => 255
      t.column :user_id, :integer, :null => false
      t.column :haiku_favorites_count, :integer, :null => false, :default => 0
      t.column :created_at, :datetime, :null => false
    end

    create_table :haiku_comments do |t|
      t.column :haiku_id, :integer, :null => false
      t.column :user_id, :integer, :null => false
      t.column :text, :string, :null => false, :limit => 1000
      t.column :created_at, :datetime, :null => false
    end
    
    create_table :haiku_favorites, :id => false do |t|
      t.column :user_id, :integer, :null => false
      t.column :haiku_id, :integer, :null => false
      t.column :created_at, :integer, :null => false
    end
    
    create_table :haiku_tags, :id => false do |t|
      t.column :haiku_id, :integer, :null => false
      t.column :tag_id, :integer, :null => false
      t.column :created_at, :datetime, :null => false
    end
    
   create_table :schools do |t|
      t.column :name, :string, :null => false, :limit => 100
      t.column :description, :string, :null => false, :limit => 1000
      t.column :isadultonly, :boolean, :null => false
      t.column :isprivate, :boolean, :null => false
      t.column :created_at, :datetime, :null => false
    end
    
    create_table :school_haikus, :id => false do |t|
      t.column :school_id, :integer, :null => false
      t.column :haiku_id, :integer, :null => false
      t.column :created_at, :datetime, :null => false
    end
    
    create_table :school_users, :id => false do |t|
      t.column :school_id, :integer, :null => false
      t.column :user_id, :integer, :null => false
      t.column :user_type, :string, :null => false
    end    

    create_table :tags do |t|
      t.column :name, :string, :null => false, :limit => 64
      t.column :haiku_tags_count, :integer, :null => false, :default => 0
      t.column :created_at, :datetime, :null => false
    end    

    create_table :users do |t|
      t.column :username, :string, :null => false, :limit => 100
      t.column :useralias, :string, :null => true, :limit => 100
      t.column :email, :string, :null => false, :limit => 100
      t.column :hashed_password, :string, :null => false
      t.column :salt, :string, :null => false
      t.column :created_at, :datetime, :null => false
    end

    create_table :user_logins, :id => false do |t|
      t.column :user_id, :integer, :null => false
      t.column :logindate, :datetime, :null => false
    end
    
    create_table :user_users, :id => false do |t|
      t.column :sourceuser_id, :integer, :null => false
      t.column :targetuser_id, :integer, :null => false
      t.column :accepted, :boolean, :null => false
    end
  end

  def self.down
    drop_table :schools
    drop_table :school_haikus
    drop_table :school_users
    drop_table :haikus
    drop_table :haiku_comments
    drop_table :haiku_favorites
    drop_table :haiku_tags
    drop_table :tags
    drop_table :users
    drop_table :user_logins
    drop_table :user_users
  end
end