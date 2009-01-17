class Authors::SubjectsController < ApplicationController
  def index
    @subjects = Author.find_by_username(params[:author_id]).haikus
  end

  def show
    @subject = Author.find_by_username(params[:author_id]).haikus.find_by_subject_name(params[:id])
  end
end