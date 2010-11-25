class JournalController < ApplicationController
  login_filter

  def index
    respond_to do |f|
      f.html do
        @haikus = current_author.haikus.recent.paginate(
          :page      => params[:page],
          :per_page  => 10,
          :total_entries => current_author.haikus_count_total
        )
      end
      f.text { render :text => current_author.haikus.map { |haiku| haiku.text}.join("\n\n") }
    end
  end

  def subjects
    if params[:id]
      @haikus = current_author.haikus.recent.find_all_by_subject_name(params[:id]).paginate(
        :page      => params[:page],
        :per_page  => 10
      )
      render "haikus_by_subject"
    else
      @subjects = current_author.subjects
    end
  end
end