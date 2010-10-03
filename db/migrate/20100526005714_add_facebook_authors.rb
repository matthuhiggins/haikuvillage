class AddFacebookAuthors < ActiveRecord::Migration
  def self.up
    change_table :authors do |t|
      t.integer :fb_uid, :null => true, :limit => 8
      t.change  :hashed_password, :string, :null => true
      t.index :fb_uid, :unique => true
    end
  end

  def self.down
  end
end
