class ConversationsController < ApplicationController
  def index
    @conversations = Conversation.active.paginate(:page => params[:page], :per_page => 15)
  end

  def show
    @conversation = Conversation.find(params[:id])
    @haikus = @conversation.haikus.paginate(:page => params[:page], :per_page => 20)
    unless @conversation.inspiration.nil?
      @inspiration = @conversation.inspiration
      render :action => "flickr_inspiration"
    end
  end
end