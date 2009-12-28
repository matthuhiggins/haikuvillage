class AddAvatar < ActiveRecord::Migration
  def self.up
    add_column :authors, :avatar_file_name,    :string
    add_column :authors, :avatar_content_type, :string
    add_column :authors, :avatar_file_size,    :integer
    add_column :authors, :avatar_updated_at,   :datetime
  end
end