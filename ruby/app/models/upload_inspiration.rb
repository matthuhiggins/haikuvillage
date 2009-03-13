class UploadInspiration < ActiveRecord::Base
  inspired_by :upload
  has_attached_file :inspiration, :default_url => "/images/inspirations/:style.png",
                             :styles => { :large => "240x240>", :medium => "75x75>", :small => "32x32>" }

  def to_path(size_type = '')
    "/system/inspirations/#{id}/#{size_type}/#{inspiration_file_name}"
  end
  
  def small
    to_path("medium")
  end
  
  def thumbnail
    to_path("large")
  end
end