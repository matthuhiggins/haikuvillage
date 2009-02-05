class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages, :force => true do |t|
      t.integer :author_id, :sender_id, :recipient_id, :null => false
      t.text :text, :limit => 153, :null => false
      t.boolean :unread, :null => false
      t.timestamps
    end
    
    add_foreign_key :messages, :author_id, :authors
    add_foreign_key :messages, :sender_id, :authors
    add_foreign_key :messages, :recipient_id, :authors
  end

# 20090129175715  
end