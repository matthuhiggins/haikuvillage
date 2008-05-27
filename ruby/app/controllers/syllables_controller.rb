class SyllablesController < ApplicationController
  def index
    words = params[:words].split("-").collect do |word|
      word = URI.unescape(word)
      Word.new(word)
    end
    
    render :json => words
  end  
end