class ForeignKeys < ActiveRecord::Migration
  def self.up  
    add_foreign_key :haikus, :author_id, :authors
    
    add_foreign_key :haiku_favorites, :haiku_id, :haikus
    add_foreign_key :haiku_favorites, :author_id, :authors
  end
end