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
    set_inspiration_variables
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
  
  def friends
    @mentors = current_author.mentors# .mutual
    @disciples = current_author.disciples# .fans
  end
  
  def get_inspired
    set_inspiration_variables
    render :partial => "get_inspired"
  end
  
  private
    def set_inspiration_variables
      offset = (params[:offset] || rand(10)).to_i
      @inspiration = FlickrInspiration.first(:offset => offset, :order => "created_at desc")
      @prev_offset = (offset - 1) % 10
      @next_offset = (offset + 1) % 10
    end
end