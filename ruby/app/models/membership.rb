class Membership < ActiveRecord::Base
  belongs_to :group, :counter_cache => true
  belongs_to :author
end