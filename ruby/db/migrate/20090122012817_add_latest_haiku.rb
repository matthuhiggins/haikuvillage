class AddLatestHaiku < ActiveRecord::Migration
  def self.up
    change_table :authors do |t|
      t.integer :latest_haiku_id
    end
    
    add_foreign_key :authors, :latest_haiku_id, :haikus
  end

  def self.down
  end
end
