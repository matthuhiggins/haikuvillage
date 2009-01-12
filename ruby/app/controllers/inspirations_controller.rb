class InspirationsController < ApplicationController
  def show
    @conversation = Conversation.find(params[:id])
    @inspiration = @conversation.inspiration
  end

  def random
    offset = (params[:offset] || 1).to_i
    @inspiration = FlickrInspiration.first(:offset => offset, :order => "created_at desc")
    @next_offset = (offset + 1) % 10
    render :partial => "random"
  end
end