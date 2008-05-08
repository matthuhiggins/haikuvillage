class SyllablesController < ApplicationController
  def count
    words = params[:word].split("-").collect do |word|
      word = URI.unescape(word)
      get_cache("word_count:#{word}") { Word.new(word) }
    end
    
    respond_to do |format|
      format.json { render :text => words.to_json }
    end
  end
  
  acts_as_cached

end