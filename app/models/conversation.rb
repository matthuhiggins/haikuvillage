class Conversation < ActiveRecord::Base
  extend ActiveSupport::Memoizable

  has_many :haikus
  has_one :flickr_inspiration
  has_one :upload_inspiration

  named_scope :active, :order => "latest_haiku_update desc", :conditions => "haikus_count_total > 0"

  def recent_haikus
    haikus.recent.all(:limit => 3)
  end
  memoize :recent_haikus

  def inspiration
    if inspiration_type.nil?
      nil
    else
      send("#{inspiration_type}_inspiration")
    end
  end
end