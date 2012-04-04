class Subject < ActiveRecord::Base
  has_many :haikus
  has_many :authors, through: :haikus
  
  scope :popular, :order => "haikus_count_total desc"
  scope :hot, :order => "haikus_count_week desc"
  scope :recent, :order => "created_at desc"
  scope :search, lambda { |query| {:conditions => ['name like ?', "#{query}%"]} }
  
  def to_param
    "#{id}-#{name.parameterize}"
  end
end