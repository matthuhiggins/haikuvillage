class SyllablesController < ApplicationController
  require "lingua/syllable"

  def count
    render :text => syllable_count(params[:word])
  end

  def count_json
    out = ""
    out << "{"
    out << "'word': '" << params[:word] << "',"
    out << "'syllables':" << syllable_count(params[:word]).to_s << ","
    out << "}"
    render :text => out
  end

  def syllable_count( word )
    Lingua::EN::Syllable.syllables(word)
  end 
end