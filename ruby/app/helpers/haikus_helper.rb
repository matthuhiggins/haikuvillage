module HaikusHelper
  def new_haiku?(haiku)
    haiku.id == flash[:new_haiku_id]
  end
  
  def haiku_title(haiku)
    text = "A haiku by #{haiku.author.username}"
    if !haiku.conversation.nil? && haiku.conversation.inspiration_type == 'flickr'
      text <<  ", inspired by #{link_to 'Flickr', inspiration_url(haiku.conversation)}"
    end
    text
  end

  def subject_auto_complete
    text_field_with_auto_complete :haiku, :subject_name, {:maxlength => 24, :size => 10}, {
      :url => suggest_subjects_path, 
      :method => :get, 
      :param_name => 'q'}
  end
  
  def enter_conversation_link(haiku)
    unless haiku.conversing?
      content_tag(:div, link_to("Respond to this haiku", haiku), :class => "action")
    else
      ""
    end
  end
  
  def destroy_haiku_link(haiku)
    if haiku.author == current_author
      image = image_tag("icons/trash.png", :alt => "Delete")
      content_tag(:div, link_to(image, haiku, :method => :delete), :class => "action")
    end
  end
  
  def email_haiku_link(haiku)
      content_tag(:div, link_to("Email this haiku", email_haiku_url(haiku)), :class => "action")
  end
  
  def haiku_text_tag
    text_area_tag(:text, "five syllables\nseven syllables\nfive syllables",
      :autocomplete => 'off',
      :rows => 3,
      :id => "haiku_text",
      :name => "haiku[text]",
      :class => "empty")
  end
end