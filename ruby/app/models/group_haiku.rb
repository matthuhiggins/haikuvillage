class GroupHaiku < ActiveRecord::Base
  belongs_to :group
  belongs_to :haiku
end
