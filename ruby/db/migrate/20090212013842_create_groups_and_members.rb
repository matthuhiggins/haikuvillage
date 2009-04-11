class CreateGroupsAndMembers < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :name, :null => false
      t.text :description, :null => false
      t.boolean :invite_only, :null => false
      t.integer :haikus_count, :memberships_count, :null => false, :default => 0
      t.string :logo_file_name, :logo_content_type
      t.integer :logo_file_size
      t.datetime :logo_updated_at
      t.timestamps
    end
    add_index :groups, :name, :unique => true

    create_table :memberships do |t|
      t.references :author, :group, :null => false
      t.integer :standing, :null => false
      t.timestamps
    end
    add_index :memberships, [:author_id, :group_id, :standing]
    add_index :memberships, [:group_id, :author_id], :unique => true
    
    change_table :haikus do |t|
      t.references :group, :null => true
    end
  end
end
