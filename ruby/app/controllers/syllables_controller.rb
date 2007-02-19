class SyllablesController < ApplicationController

  def count
    words = params[:word].split("-").collect { |word| Word.new(URI.unescape(word)) }
    respond_to do |format|
      format.json { render :text => words.to_json }
    end
  end

end