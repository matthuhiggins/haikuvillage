class AddResponses < ActiveRecord::Migration
  def self.up
    change_table :haikus do |t|
      t.integer :responding_to_id, :null => true
      t.integer :responses_count_week, :responses_count_total, :null => false, :default => 0
      t.index :responses_count_week
      t.index :responses_count_total
    end
  end
end
