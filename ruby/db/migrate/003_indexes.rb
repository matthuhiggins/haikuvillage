class Indexes < ActiveRecord::Migration
  
  def self.up
    add_index :haikus, :user_id
    add_index :haikus, :favorited_count_week
    add_index :haikus, :favorited_count_month
    add_index :haikus, :favorited_count_total
    
    add_index :users, :username

    add_index :haiku_favorites, [:user_id, :haiku_id, :created_at]
    add_index :haiku_favorites, [:haiku_id, :user_id], :unique => true
  end
end