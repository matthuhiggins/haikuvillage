class UploadInspiration < ActiveRecord::Base
  inspired_by :upload

  def small
    # inspiration.url(:medium)
  end
  
  def thumbnail
    # inspiration.url(:large)
  end
end