class PopularUsers < ActiveRecord::Migration
  def self.up
    change_table :authors do |t|
      t.integer :favorited_count_total, :favorited_count_week, :null => false, :default => 0
    end
    
    execute %{
      update authors a
      join (select count(*) as total, author_id
            from haiku_favorites
            group by author_id) lovers
       on a.id = lovers.author_id 
      set a.favorited_count_total = lovers.total
         ,a.favorited_count_week =  lovers.total
    }
  end
  
  def self.down
    change_table :authors do |t|
      t.remove :favorited_count_total, :favorited_count_week
    end
  end
end
