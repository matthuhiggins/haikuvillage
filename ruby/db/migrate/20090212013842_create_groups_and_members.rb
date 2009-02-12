class CreateGroupsAndMembers < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :title, :null => false
      t.text :description
      t.boolean :invite_only, :null => false
      t.timestamps
    end

    create_table :members do |t|
      t.references :author, :group, :null => false
      t.boolean :admin, :null => false
      t.integer :status, :null => false
      t.timestamps
    end
    add_foreign_key :members, :author_id, :authors
    add_foreign_key :members, :group_id, :groups
    
    change_table :haikus do |t|
      t.references :group
    end
    add_foreign_key :haikus, :group_id, :groups
  end
end
