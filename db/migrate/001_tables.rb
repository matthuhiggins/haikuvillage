class Tables < ActiveRecord::Migration
  def self.up  
    create_table :authors do |t|
      t.string :username, :password, :null => false
      t.integer :haikus_count_week, :haikus_count_total, :null => false, :default => 0
      t.integer :favorites_count, :null => false, :default => 0
      t.timestamps
    end
    add_index :authors, :username, :unique => true
    add_index :authors, :haikus_count_week
    add_index :authors, :haikus_count_total

    create_table :haikus do |t|
      t.integer :twitter_status_id, :null => false
      t.references :author, :null => false
      t.integer :favorited_count_week, :favorited_count_total, :null => false, :default => 0
      t.integer :view_count_week, :view_count_total, :null => false, :default => 0
      t.text :text, :null => false
      t.timestamps
    end
    add_index :haikus, :favorited_count_week
    add_index :haikus, :favorited_count_total
    add_index :haikus, :view_count_week
    add_index :haikus, :view_count_total
    add_foreign_key :haikus, :authors

    create_table :haiku_favorites do |t|
      t.references :author, :haiku, :null => false
      t.timestamps
    end
    add_index :haiku_favorites, [:author_id, :haiku_id, :created_at]
    add_index :haiku_favorites, [:haiku_id, :author_id], :unique => true
    add_index :haiku_favorites, [:created_at, :haiku_id]
    add_foreign_key :haiku_favorites, :authors
    add_foreign_key :haiku_favorites, :haikus
  end
end