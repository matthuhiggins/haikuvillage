class SyllablesController < ApplicationController  
  def index
    words = params[:words].split("-").map { |word| URI.unescape(word) }
    render :json => words.map { |word| {:text => word, :syllables => word.syllables} }
  end  
end