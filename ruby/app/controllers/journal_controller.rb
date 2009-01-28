class JournalController < ApplicationController
  login_filter
  
  def index
    @haikus = current_author.haikus.paginate({
      :order     => "haikus.id desc",
      :include   => :author,
      :page      => params[:page],
      :per_page  => 10,
      :total_entries => current_author.haikus_count_total
    })
    @inspirations = FlickrInspiration.all(:limit => 10, :order => "id desc").map { |f| {:thumbnail => f.thumbnail, :id => f.conversation_id} }
  end

  def favorites
    @haikus = current_author.favorites.paginate({
      :order     => "haikus.id desc",
      :include   => :author,
      :page      => params[:page],
      :per_page  => 10,
      :total_entries => current_author.favorited_count_total
    })
  end
  
  def subjects
    if params[:id]
      @subject = current_author.subjects.find_by_name!(params[:id])
      @haikus = @subject.haikus
    else
      @subjects = current_author.subjects
    end
  end
  
  def friends
    @friends = current_author.friends
  end
end