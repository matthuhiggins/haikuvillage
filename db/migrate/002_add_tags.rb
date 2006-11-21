class AddTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.column :name, :string
    end
    
    create_table( :haiku_tags, :id => false ) do |t|
      t.column :haiku_id, :integer, :null => false
      t.column :tag_id, :integer, :null => false
    end
    
    add_index( :haiku_tags, :haiku_id )
    add_index( :haiku_tags, :tag_id )
  end

  def self.down
    drop_table :haiku_tags
    drop_table :tags
  end
end
