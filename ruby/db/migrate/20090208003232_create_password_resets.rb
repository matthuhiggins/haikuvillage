class CreatePasswordResets < ActiveRecord::Migration
  def self.up
    create_table :password_resets do |t|
      t.string :token, :null => false
      t.references :author
      t.timestamps
    end
    
    add_index :password_resets, :token, :unique => true
  end
end
