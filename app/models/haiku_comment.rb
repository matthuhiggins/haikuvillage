class HaikuComment < ActiveRecord::Base
  belongs_to :haiku
end