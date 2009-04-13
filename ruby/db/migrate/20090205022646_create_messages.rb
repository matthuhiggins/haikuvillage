class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages, :force => true do |t|
      t.references :author, :null => false
      t.integer :sender_id, :recipient_id, :null => false
      t.text :text, :limit => 153, :null => false
      t.boolean :unread, :null => false
      t.timestamps
    end
    add_foreign_key :messages, :authors
    add_foreign_key :messages, :authors, :column => :sender_id 
    add_foreign_key :messages, :authors, :column => :recipient_id
  end
end