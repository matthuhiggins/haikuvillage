class AddLatestHaiku < ActiveRecord::Migration
  def self.up
    change_table :authors do |t|
      t.integer :latest_haiku_id
      t.foreign_key :haikus, :column => :latest_haiku_id, :dependent => :nullify
    end
  end
end
