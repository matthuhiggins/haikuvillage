class SchoolHaiku < ActiveRecord::Base
  belongs_to :school
  belongs_to :haiku
end