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
end