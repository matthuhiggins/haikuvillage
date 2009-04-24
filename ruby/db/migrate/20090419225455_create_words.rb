class CreateWords < ActiveRecord::Migration
  def self.up
    create_table :words, :id => false do |t|
      t.text :text, :null => false
      t.integer :syllables, :null => true
      t.timestamps
    end
    add_index :words, :text, :unique => true
  end

  def self.down
    drop_table :words
  end
end
