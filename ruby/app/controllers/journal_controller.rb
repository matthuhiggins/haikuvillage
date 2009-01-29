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
    @haikus = current_author.favorites.recent.paginate({
      :page      => params[:page],
      :per_page  => 10,
      :total_entries => current_author.favorited_count_total
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
    @friends = current_author.friends
  end
end