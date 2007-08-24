class SearchController < ApplicationController

  layout "haikus"

  def haikus
    @haikus = load_items(Haiku)
  end
  
  def groups
    @groups = load_items(Group)
  end
  
  private
    def load_items(klass)
      unless params[:q].blank?
        current = 1 unless params[:p]
        klass.paginating_ferret_search({:q => params[:q],
                                        :current => 1,
                                        :page_size => 4})
      end
    end
end