class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages, :force => true do |t|
      t.references :friendship, :null => false
      t.text :text, :limit => 153, :null => false
      t.timestamps
    end
    
    add_foreign_key :messages, :friendship_id, :friendships
  end
end
