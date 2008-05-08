class SyllablesController < ApplicationController
  def count
    words = params[:word].split("-").collect do |word|
      get_cache("word_count:#{word}") { Word.new(URI.unescape(word)) }
    end
    
    respond_to do |format|
      format.json { render :text => words.to_json }
    end
  end
  
  acts_as_cached

end