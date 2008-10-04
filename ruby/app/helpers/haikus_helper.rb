module HaikusHelper
  def new_haiku?(haiku)
    haiku.id == flash[:new_haiku_id]
  end
  
  def subject_auto_complete
    text_field_with_auto_complete :haiku, :subject_name, {:maxlength => 24, :size => 10}, {
      :url => suggest_subjects_path, 
      :method => :get, 
      :param_name => 'q'}
  end
  
  def haiku_title(haiku)
    text = "A haiku by #{haiku.author.username}"
    if !@single_haiku.conversation.nil? && haiku.conversation.inspiration_type == 'flickr'
      text <<  ", inspired by #{link_to 'Flickr', inspiration_url(haiku.conversation)}"
    end
    text
  end
  
  def haiku_sort_link(order)
    link_to_unless(haiku_sort_param == order, order.to_s.humanize, :order => order)
  end
  
  def link_to_add_statement(name, html_id)
    link_to_function name, nil, :id => html_id do |page|
      page[html_id].hide
      page[:statement_form].visual_effect(:blind_down, :duration => 0.2)
    end
  end
end