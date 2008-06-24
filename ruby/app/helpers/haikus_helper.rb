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
  
  def haiku_sort_link(order)
    link_to_unless(haiku_sort_param == order, order.to_s.humanize, :order => order)
  end
end