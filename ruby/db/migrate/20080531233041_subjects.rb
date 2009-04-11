class Subjects < ActiveRecord::Migration
  def self.up
    create_table :subjects do |t|
      t.string :name, :null => false
      t.integer :haikus_count_week, :haikus_count_total, :null => false, :default => 0
      t.timestamps
    end
    
    add_index :subjects, :name, :unique => true 
    add_index :subjects, :haikus_count_week
    add_index :subjects, :haikus_count_total
    add_index :subjects, :created_at
    
    change_table :haikus do |t|
      t.string :subject_name, :null => true
      t.integer :subject_id, :null => true
    end
    
    add_index :haikus, [:subject_id, :created_at]
    add_foreign_key :haikus, :subjects
  end
end