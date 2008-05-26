class Tables < ActiveRecord::Migration
  def self.up  
    create_table :haikus do |t|
      t.integer :twitter_status_id, :author_id, :null => false
      t.integer :favorited_count_week, :favorited_count_total, :null => false, :default => 0
      t.integer :view_count_week, :view_count_total, :null => false, :default => 0
      t.text :text, :limit => 153, :null => false
      t.timestamps
    end
    
    create_table :authors do |t|
      t.string :username, :password, :null => false
      t.integer :haikus_count_week, :haikus_count_total, :null => false, :default => 0
      t.integer :favorites_count, :null => false, :default => 0
      t.timestamps
    end
    
    create_table :haiku_favorites do |t|
      t.integer :author_id, :haiku_id, :null => false
      t.timestamps
    end
  end
end