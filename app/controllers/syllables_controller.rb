class SyllablesController < ApplicationController
  require "lingua/syllable"

  def count
    words = params[:word].split("-").collect { |word| Word.new(word) }
    respond_to do |format|
      format.json { render :text => words.to_json }
    end
    
  end

end