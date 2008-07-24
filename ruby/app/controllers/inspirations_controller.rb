class InspirationsController < ApplicationController
  def flickr
    if params[:id]
      @inspiration = FlickrInspiration.find(params[:id])
      render :action => 'flickr_single'
    else
      @inspirations = FlickrInspiration.all
      render :action => 'flickr_list'
    end
  end
end