class SyllablesController < ApplicationController
  require "lingua/syllable"

  def count
    render :text => syllable_count(params[:word])
  end

  def count_json
    render :text => params[:word].split("-").collect { |word| Word.new(word) }.to_json
  end

end