class Indexes < ActiveRecord::Migration
  def self.up
    add_index :haikus, :author_id
    add_index :haikus, :favorited_count_week
    add_index :haikus, :favorited_count_total
    add_index :haikus, :view_count_week
    add_index :haikus, :view_count_total
    
    add_index :authors, :username
    add_index :authors, :haikus_count_week
    add_index :authors, :haikus_count_total

    add_index :haiku_favorites, [:author_id, :haiku_id, :created_at]
    add_index :haiku_favorites, [:haiku_id, :author_id], :unique => true
    add_index :haiku_favorites, [:created_at, :haiku_id]
  end
end