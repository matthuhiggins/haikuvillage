class UploadInspiration < ActiveRecord::Base
  inspired_by :upload
  has_attached_file :inspiration, :default_url => "/images/inspirations/:style.png",
                             :styles => { :large => "240x240>", :medium => "75x75>", :small => "32x32>" }
  
  def small
    inspiration.url(:medium)
  end
  
  def thumbnail
    inspiration.url(:large)
  end
end