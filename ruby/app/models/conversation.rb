class Conversation < ActiveRecord::Base
  has_many :haikus
  has_one :flickr_inspiration

  named_scope :active, :order => :updated_at # last_haiku_added

  def recent_haikus
    haikus.recent.all(:limit => 4)
  end

  def inspiration
    if inspiration_type.nil?
      nil
    else
      send("#{inspiration_type}_inspiration")
    end
  end
end