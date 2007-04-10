class SearchController < ApplicationController

  layout "haikus"

  def haikus
    unless params[:q].blank?
      current = 1 unless params[:p]
      @haikus = Haiku.paginating_ferret_search({:q => params[:q],
                                                :current => 1,
                                                :page_size => 4})
    end
  end
  
  def groups
    unless params[:q].blank?
      current = 1 unless params[:p]
      @groups = Group.paginating_ferret_search({:q => params[:q],
                                                :current => 1,
                                                :page_size => 4})
    end
  end
  
end