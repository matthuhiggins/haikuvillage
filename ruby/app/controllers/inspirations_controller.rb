class InspirationsController < ApplicationController
  def flickr
    @inspirations = FlickrInspiration.all
    render :action => 'flickr_list'
  end
  
  def show
    @conversation = Conversation.find(params[:id])
    # This needs to be abstacted to use the 'inspiration_type' from the conversation table
    @inspiration = FlickrInspiration.first(:conditions => {:conversation_id => @conversation.id})
  end
end