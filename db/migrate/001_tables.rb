class Tables < ActiveRecord::Migration
  def self.up  
    create_table :authors do |t|
      t.string :email, :username, :password, :null => false
      t.integer :haikus_count_week, :haikus_count_total, :null => false, :default => 0
      t.integer :favorited_count_total, :favorited_count_week, :null => false, :default => 0
      t.integer :favorites_count, :null => false, :default => 0
      t.timestamps
    end
    add_index :authors, :email, :unique => true
    add_index :authors, :username, :unique => true
    add_index :authors, :haikus_count_week

    create_table :haikus do |t|
      t.references :author, :null => false
      t.text :text, :null => false
      t.integer :favorited_count, :null => false, :default => 0
      t.timestamps
    end
    add_foreign_key :haikus, :authors

    create_table :favorites do |t|
      t.references :author, :haiku, :null => false
      t.timestamps
    end
    add_index :favorites, [:author_id, :haiku_id, :created_at]
    add_index :favorites, [:haiku_id, :author_id], :unique => true
    add_index :favorites, [:created_at, :haiku_id]
    add_foreign_key :favorites, :authors
    add_foreign_key :favorites, :haikus
  end
end