class AddLatestHaiku < ActiveRecord::Migration
  def self.up
    change_table :authors do |t|
      t.integer :latest_haiku_id
    end
    
    Author.all.each do |author|
      author.latest_haiku_id = author.haikus.recent.first
    end
  end

  def self.down
  end
end
