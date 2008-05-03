class Tables < ActiveRecord::Migration
  def self.up  
    create_table :haikus do |t|
      t.string :text, :null => false, :limit => 765
      t.integer :user_id, :haiku_favorites_count, :null => false, :default => 0
      t.timestamps
    end
    
    create_table :haiku_favorites, :id => false do |t|
      t.integer :user_id, :haiku_id, :null => false
      t.timestamps
    end
  end
end
