class CreateFriends < ActiveRecord::Migration
  def self.up
    create_table :friendships do |t|
      t.integer :friend_id, :null => false
      t.references :author, :null => false
      t.boolean :mutual, :null => false
      t.timestamps
    end
    add_index :friendships, [:author_id, :friend_id], :unique => true, :name => "friendships_index"
    add_index :friendships, [:friend_id, :author_id]
    add_foreign_key :friendships, :authors
    add_foreign_key :friendships, :authors, :column => :friend_id
  end
end
