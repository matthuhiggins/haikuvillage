class AddConversations < ActiveRecord::Migration
  def self.up
    create_table :conversations do |t|
      t.integer :haikus_count_week, :haikus_count_total, :null => false, :default => 0
      t.timestamps
    end

    add_index :conversations, :haikus_count_week
    add_index :conversations, :haikus_count_total
    
    change_table :haikus do |t|
      t.references :conversation, :null => true
    end    
  end
end