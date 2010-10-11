module InspirationsHelper
  def inspirations_json
    FlickrInspiration.limit(10).order('id desc').map do |f|
      {:thumbnail => f.thumbnail, :id => f.conversation_id}
    end.to_json
  end
end