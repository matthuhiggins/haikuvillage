class Tables < ActiveRecord::Migration
  def self.up  
    create_table :users do |t|
      t.string :username, :password, :null => false
      t.timestamps
    end
    
    create_table :haikus do |t|
      t.integer :twitter_status_id, :user_id, :null => false
      t.text :haiku, :limit => 153, :null => false
      t.timestamps
    end
    
    create_table :haiku_favorites, :id => false do |t|
      t.integer :user_id, :haiku_id, :null => false
      t.timestamps
    end
  end
end