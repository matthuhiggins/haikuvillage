class ExploreController < ApplicationController
  def index
    @new_authors = Author.brand_new.all(:limit => 12)
    @new_subjects = Subject.recent.all(:limit => 12)
    @popular_subjects = Subject.popular.all(:limit => 40)
  end
end