class Subject < ActiveRecord::Base
  has_many :haikus  
  
  named_scope :popular, :order => "haikus_count desc"
  named_scope :recent, :order => "created_at desc"
  named_scope :search, lambda { |query| {:conditions => ['name like ?', "#{query}%"]} }
end