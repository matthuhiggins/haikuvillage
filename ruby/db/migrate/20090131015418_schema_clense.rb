class SchemaClense < ActiveRecord::Migration
  def self.up
    add_index :authors, :email, :unique => true

    remove_index :authors, :haikus_count_total

    remove_column :conversations, :haikus_count_week
    
    remove_column :haikus, :view_count_week
    remove_column :haikus, :view_count_total
    remove_column :haikus, :favorited_count_week
    rename_column :haikus, :favorited_count_total, :favorited_count
    
    rename_table :haiku_favorites, :favorites
  end

  def self.down
  end
end
