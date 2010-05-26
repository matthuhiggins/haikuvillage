class AddFacebookAuthors < ActiveRecord::Migration
  def self.up
    change_table :authors do |t|
      t.integer :fb_uid, :null => false, :limit => 8
      t.index :fb_uid, :unique => true
      t.change  :hashed_password, :string, :null => true
      t.change  :hashed_password, :string, :null => true
    end
  end

  def self.down
  end
end
