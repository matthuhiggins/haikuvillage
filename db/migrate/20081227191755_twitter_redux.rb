class TwitterRedux < ActiveRecord::Migration
  def self.up
    change_table :authors do |t|
      t.string :twitter_username, :twitter_password
      t.boolean :twitter_enabled, :null => false, :default => false
    end
  end

  def self.down
  end
end
