class InspirationsController < ApplicationController
  def flickr
    @inspirations = FlickrInspiration.all
    render :action => 'flickr_list'
  end
  
  def show
    @inspiration = Conversation.find(params[:id])
  end
end