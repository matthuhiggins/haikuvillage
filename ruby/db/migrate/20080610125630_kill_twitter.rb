class KillTwitter < ActiveRecord::Migration
  def self.up
    change_table :authors do |t|
      t.string :email, :null => false, :default => ''
    end
    
    change_table :haikus do |t|
      t.remove :twitter_status_id
    end
  end
end
