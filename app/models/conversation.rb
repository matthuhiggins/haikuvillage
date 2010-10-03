class Conversation < ActiveRecord::Base
  has_many :haikus
  has_one :flickr_inspiration

  named_scope :active, :order => "latest_haiku_update desc", :conditions => "haikus_count_total > 0"

  def recent_haikus
    @recent_haikus ||= haikus.recent.all(:limit => 3)
  end

  def inspiration
    if inspiration_type.nil?
      nil
    else
      send("#{inspiration_type}_inspiration")
    end
  end
end