class Subject < ActiveRecord::Base
  has_many :haikus
  
  named_scope :recent, :order => 'created_at desc'
  named_scope :popular, :order => 'haikus_count desc'
end