class CreateGroupsAndMembers < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :name, :null => false
      t.text :description
      t.boolean :members_only, :null => false
      t.integer :haikus_count, :memberships_count, :null => false, :default => 0
      t.string :avatar_file_name, :avatar_content_type
      t.integer :avatar_file_size
      t.datetime :avatar_updated_at
      t.timestamps
    end
    add_index :groups, :name, :unique => true

    create_table :memberships do |t|
      t.references :author, :group, :null => false
      t.integer :status, :null => false
      t.timestamps
    end
    add_foreign_key :memberships, :author_id, :authors
    add_foreign_key :memberships, :group_id, :groups
    
    change_table :haikus do |t|
      t.references :group, :null => true
    end
    add_foreign_key :haikus, :group_id, :groups
  end
end
