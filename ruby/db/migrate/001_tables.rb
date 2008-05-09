class Tables < ActiveRecord::Migration
  def self.up  
    create_table :users do |t|
      t.string :username, :password, :null => false
      t.integer :haikus_count, :null => false, :default => 0
      t.timestamps
    end
    
    create_table :haikus do |t|
      t.integer :twitter_status_id, :user_id, :null => false
      t.integer :haiku_favorites_count, :null => false, :default => 0
      t.text :text, :limit => 153, :null => false
      t.timestamps
    end
    
    create_table :haiku_favorites do |t|
      t.integer :user_id, :haiku_id, :null => false
      t.timestamps
    end
  end
end