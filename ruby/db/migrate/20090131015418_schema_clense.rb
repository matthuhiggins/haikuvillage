class SchemaClense < ActiveRecord::Migration
  def self.up
    add_index :authors, :email, :unique => true

    remove_index :authors, :haikus_count_total
    remove_index :authors, :author_id
    remove_index :authors, :conversation_id

    remove_column :conversations, :haikus_count_week
    remove_index :flickr_inspirations, :conversation_id
    
    remove_column :haikus, :view_count_week
    remove_column :haikus, :view_count_total
    remove_column :haikus, :favorited_count_week
  end

  def self.down
  end
end
