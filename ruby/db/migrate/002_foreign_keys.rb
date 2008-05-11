class ForeignKeys < ActiveRecord::Migration

  extend MigrationHelpers
 
  def self.up  
    add_foreign_key :haikus, :user_id, :users
    
    add_foreign_key :haiku_favorites, :haiku_id, :haikus
    add_foreign_key :haiku_favorites, :user_id, :users    
  end
end