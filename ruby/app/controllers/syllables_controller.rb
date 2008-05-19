class SyllablesController < ApplicationController
  def index
    words = params[:words].split("-").collect do |word|
      word = URI.unescape(word)
      get_cache("word_count:#{word}") { Word.new(word) }
    end
    
    render :json => words
  end
  
  acts_as_cached
end