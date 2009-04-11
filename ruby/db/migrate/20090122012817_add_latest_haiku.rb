class AddLatestHaiku < ActiveRecord::Migration
  def self.up
    change_table :authors do |t|
      t.integer :latest_haiku_id
    end
    
    add_foreign_key :authors, :haikus, :column => :latest_haiku_id, :dependent => :nullify
  end

  def self.down
  end
end
