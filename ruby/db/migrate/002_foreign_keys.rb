require "migration_helpers"

class ForeignKeys < ActiveRecord::Migration

  extend MigrationHelpers
 
  def self.up  
    # add_foreign_key :haikus, :user_id, :users
    # 
    # add_foreign_key :haiku_comments, :haiku_id, :haikus
    # add_foreign_key :haiku_comments, :user_id, :users
    # 
    # add_foreign_key :haiku_favorites, :haiku_id, :haikus
    # add_foreign_key :haiku_favorites, :user_id, :users    
    # 
    # add_foreign_key :haiku_tags, :haiku_id, :haikus
    # add_foreign_key :haiku_tags, :tag_id, :tags
    # 
    # add_foreign_key :group_haikus, :group_id, :groups
    # add_foreign_key :group_haikus, :haiku_id, :haikus
    # 
    # add_foreign_key :group_users, :group_id, :groups
    # add_foreign_key :group_users, :user_id, :users
    # 
    # add_foreign_key :user_logins, :user_id, :users
    # 
    # add_foreign_key :user_users, :sourceuser_id, :users
    # add_foreign_key :user_users, :targetuser_id, :users
  end
end