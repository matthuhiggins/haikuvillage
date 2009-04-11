class ForeignKeys < ActiveRecord::Migration
  def self.up  
    add_foreign_key :haikus, :authors
    add_foreign_key :haiku_favorites, :haikus
    add_foreign_key :haiku_favorites, :authors
  end
end