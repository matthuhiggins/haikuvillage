class JournalController < ApplicationController
  login_filter

  def index
    respond_to do |f|
      f.html do
        @haikus = current_author.feed.page(params[:page]).per(10)
      end
      f.text { render :text => current_author.haikus.map { |haiku| haiku.text}.join("\n\n") }
    end
  end

  def subjects
    if params[:id]
      @haikus = current_author.haikus.recent.where(subject_name: params[:id]).page(params[:page]).per(10)
      render "haikus_by_subject"
    else
      @subjects = current_author.subject_summary
    end
  end
end