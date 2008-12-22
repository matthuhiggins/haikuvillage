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
    inspirations = FlickrInspiration.all(:limit => 10, :order => "created_at desc")
    max_offset = [10, inspirations.size].min
    offset = [(params[:offset] || 1).to_i, inspirations.size - 1].min
    @next_offset = (offset + 1) % 10
    logger.debug("new offset = #{@next_offset}")
    logger.debug("size = #{inspirations.size}")
    @inspiration = inspirations[offset]
    render :partial => "random"
  end
end