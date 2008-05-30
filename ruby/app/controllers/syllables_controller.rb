class SyllablesController < ApplicationController
  caches_action :index, :cache_path => Proc.new { |controller| controller.params[:words] }
  
  def index
    words = params[:words].split("-").collect do |word|
      word = URI.unescape(word)
      Word.new(word)
    end
    
    render :json => words
  end  
end