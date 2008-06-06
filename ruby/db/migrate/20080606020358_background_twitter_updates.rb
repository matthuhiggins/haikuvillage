class BackgroundTwitterUpdates < ActiveRecord::Migration
  def self.up
    change_table :haikus do |t|
      t.change :twitter_status_id, :integer, :null => true
      t.index :twitter_status_id
    end
  end
end