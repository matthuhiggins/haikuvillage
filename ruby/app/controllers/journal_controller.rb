class JournalController < ApplicationController
  login_filter

  def index
    @haikus = current_author.haikus.recent.paginate({
      :page      => params[:page],
      :per_page  => 10,
      :total_entries => current_author.haikus_count_total
    })
    @inspirations = FlickrInspiration.all(:limit => 10, :order => "id desc").map { |f| {:thumbnail => f.thumbnail, :id => f.conversation_id} }
  end

  def favorites
    @haikus = current_author.favorite_haikus.recent.paginate({
      :page      => params[:page],
      :per_page  => 10,
      :total_entries => current_author.favorites_count
    })
  end

  def subjects
    if params[:id]
      @haikus = current_author.haikus.recent.find_all_by_subject_name(params[:id]).paginate(
        :page      => params[:page],
        :per_page  => 10
      )
      render :action => "haikus_by_subject"
    else
      @subjects = current_author.subjects
    end
  end

  def friends
    @friends = current_author.friends.recently_updated
  end
  
  def messages
    if request.post?
      recipient = Author.find(params[:message][:recipient_id])
      Message.transmit(current_author, recipient, params[:message][:text])
      flash[:notice] = "Message sent to #{recipient.username}"
    end

    current_author.messages.unread.update_all(:unread => false)
    @messages = current_author.messages.paginate(:page => params[:page], :per_page  => 20)
    @friends = current_author.mutual_friends.all(:order => 'username')
  end
end