class CreateHaikus < ActiveRecord::Migration
  def self.up
    create_table :haikus do |t|
      t.column :title, :string
      t.column :line1, :string
      t.column :line2, :string
      t.column :line3, :string
    end
  end

  def self.down
    drop_table :haikus
  end
end
