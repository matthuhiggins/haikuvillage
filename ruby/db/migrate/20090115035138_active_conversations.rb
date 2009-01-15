class ActiveConversations < ActiveRecord::Migration
  def self.up
    change_table :conversations do |t|
      t.datetime :latest_haiku_update
    end
    
    add_index :conversations, :latest_haiku_update
  end
end
