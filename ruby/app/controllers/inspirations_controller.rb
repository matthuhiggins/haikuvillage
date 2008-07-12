class InspirationsController < ApplicationController
  def flickr
    @inspirations = FlickrInspiration.all
  end
end