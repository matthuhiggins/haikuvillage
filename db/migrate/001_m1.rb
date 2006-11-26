class M1 < ActiveRecord::Migration
  def self.up
   create_table :groups do |t|
      t.column :name, :string, :null => false, :limit => 100
      t.column :description, :text, :null => false
      t.column :isadultonly, :boolean, :null => false
      t.column :isprivate, :boolean, :null => false
      t.column :created_at, :datetime
    end
#    
#    create_table "grouptopics" do |t|
#      t.column "grouptopicname", :string
#      t.column "groupid", :integer
#      t.column "created_at", :integer
#    end
#    

    create_table :group_haikus, :id => false do |t|
      t.column :group_id, :integer, :null => false
      t.column :haiku_id, :integer, :null => false
    end
    
    create_table :group_users, :id => false do |t|
      t.column :group_id, :integer, :null => false
      t.column :user_id, :integer, :null => false
      t.column :groupusertype_id, :integer, :null => false
    end
    
    create_table :group_user_types do |t|
      t.column :name, :string, :null => false
    end
    
    create_table :haiku_comments do |t|
      t.column :haiku_id, :integer, :null => false
      t.column :user_id, :integer, :null => false
      t.column :text, :text, :null => false
      t.column :created_at, :datetime, :null => false
    end
    
    create_table :haikus do |t|
      t.column :title, :string, :null => false, :limit => 100
      t.column :line1, :string, :null => false, :limit => 255
      t.column :line2, :string, :null => false, :limit => 255
      t.column :line3, :string, :null => false, :limit => 255
      t.column :user_id, :string, :null => false
      t.column :created_at, :datetime, :null => false
    end
    
    create_table :haiku_tags, :id => false do |t|
      t.column :haiku_id, :integer, :null => false
      t.column :tag_id, :integer, :null => false
      t.column :created_at, :datetime, :null => false
    end

    create_table :tags do |t|
      t.column :name, :string, :null => false, :limit => 64
    end
    
    create_table :user_haiku_favorites, :id => false do |t|
      t.column :user_id, :integer, :null => false
      t.column :haiku_id, :integer, :null => false
      t.column :created_at, :integer, :null => false
    end

    create_table :user_logins, :id => false do |t|
      t.column :user_id, :integer, :null => false
      t.column :logindate, :integer, :null => false
    end

    create_table :users do |t|
      t.column :username, :string, :null => false, :limit => 100
      t.column :useralias, :string, :null => true, :limit => 100
      t.column :email, :string, :null => false, :limit => 100
      t.column :hashpassword, :string, :null => false
      t.column :salt, :string, :null => false
      t.column :created_at, :string, :null => false
    end
    
    create_table :user_users, :id => false do |t|
      t.column :sourceuser_id, :integer, :null => false
      t.column :targetuser_id, :integer, :null => false
      t.column :accepted, :boolean, :null => false
    end
  end

  def self.down
    drop_table :groups
    drop_table :group_haikus
    drop_table :group_users
    drop_table :group_user_types
    drop_table :haiku_comments
    drop_table :haikus
    drop_table :haiku_tags
    drop_table :tags
    drop_table :user_haiku_favorites
    drop_table :user_logins
    drop_table :users
    drop_table :user_users
  end
end
