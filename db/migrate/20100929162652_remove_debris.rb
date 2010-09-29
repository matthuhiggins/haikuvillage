class RemoveDebris < ActiveRecord::Migration
  def self.up
    change_table :haikus do |t|
      t.remove_foreign_key :groups
      t.remove :group_id
    end

    drop_table :memberships
    drop_table :groups
    drop_table :logged_exceptions

    change_table :authors do |t|
      t.remove :twitter_username
      t.remove :twitter_password
      t.remove :twitter_enabled
    end
  end

  def self.down
  end
end
