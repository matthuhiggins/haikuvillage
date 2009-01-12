class ConversationsController < ApplicationController
  def index
    @conversations = Conversation.active.paginate(:page => params[:page], :per_page => 15)
  end

  def show
    @conversation = Conversation.find(params[:id])
  end
end