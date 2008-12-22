class InspirationsController < ApplicationController
  def flickr
    @inspirations = FlickrInspiration.all(:order => 'created_at desc', :limit => 12)
    render :action => 'flickr_list'
  end
  
  def show
    @conversation = Conversation.find(params[:id])
    # This needs to be abstacted to use the 'inspiration_type' from the conversation table
    @inspiration = @conversation.inspiration
  end
  
  def random
    offset = (params[:offset] || 1).to_i
    @inspiration = FlickrInspiration.first(:offset => offset, :order => "created_at desc")
    @next_offset = (offset + 1) % 10
    render :partial => "random"
  end
end