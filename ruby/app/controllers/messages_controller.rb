class MessagesController < ApplicationController
  login_filter

  def index
    current_author.messages.unread.update_all(:unread => false)
    @messages = current_author.messages.paginate(:page => params[:page], :per_page  => 20)
    @friends = current_author.mutual_friends.all(:order => 'username')
  end
  
  def create
    recipient = Author.find(params[:message][:recipient_id])
    Message.transmit(current_author, recipient, params[:message][:text])
    flash[:notice] = "Message sent to #{recipient.username}"
    redirect_to(messages_url)
  end
end