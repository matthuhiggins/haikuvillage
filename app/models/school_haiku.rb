class SchoolHaiku < ActiveRecord::Base
  has_one :school
  has_one :haiku
end