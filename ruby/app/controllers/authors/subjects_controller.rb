class Authors::SubjectsController < ApplicationController
  def index
    @author = Author.find_by_username(params[:author_id])
    @subjects = @author.subjects
  end

  def show
    @author = Author.find_by_username(params[:author_id])
    @haikus = @author.haikus.find_by_subject_name(params[:id])
  end
end