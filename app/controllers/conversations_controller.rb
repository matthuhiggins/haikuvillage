class ConversationsController < ApplicationController
  def index
    @conversations = Conversation.active.page(params[:page]).per(15)
  end

  def show
    @conversation = Conversation.find(params[:id])
    @haikus = @conversation.haikus.page(params[:page]).per(20)
    unless @conversation.inspiration.nil?
      @inspiration = @conversation.inspiration
      render "inspired"
    end
  end
end