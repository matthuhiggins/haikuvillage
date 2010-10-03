class Subject < ActiveRecord::Base
  has_many :haikus  
  
  scope :popular, :order => "haikus_count_total desc"
  scope :hot, :order => "haikus_count_week desc"
  scope :recent, :order => "created_at desc"
  scope :search, lambda { |query| {:conditions => ['name like ?', "#{query}%"]} }
end