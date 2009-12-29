module HaikusHelper
  def render_haikus(haikus)
    render :partial => "haikus/haiku", :collection => haikus, :spacer_template => "conversations/divider"
  end

  # options include:
  #   conversing_with - The haiku that this creation is in reference too
  #   conversation - An existing conversation that this haiku is being added to
  #   group - The group that this haiku is being contributed to
  #   inspire - Show the inspiration upload/image options
  def render_create(options = {})
    render :partial => "haikus/create", :locals => options
  end

  def new_haiku?(haiku)
    haiku.id == flash[:new_haiku_id]
  end
  
  def haiku_title(haiku)
    "A haiku by #{link_to haiku.author.username, author_path(haiku.author.username)}"
  end

  def subject_auto_complete
    text_field_with_auto_complete :haiku, :subject_name, {:maxlength => 24, :size => 10}, {
      :url => suggest_subjects_path, 
      :method => :get, 
      :param_name => 'q'}
  end
  
  def enter_conversation_link(haiku)
    polymorphic_path = haiku.conversing? ? haiku.conversation : haiku
    link_tag = link_to("Respond", polymorphic_path, :class => "icon reply")
    content_tag(:div, link_tag, :class => "action")
  end
  
  def destroy_haiku_link(haiku)
    if haiku.author == current_author
      link_tag = link_to('Delete', haiku, :method => :delete, :class => 'icon trash')
      content_tag(:div, link_tag, :class => "action")
    end
  end
  
  def email_haiku_link(haiku)
    link_tag = link_to("Email", email_haiku_path(haiku), :class => "icon email")
    content_tag(:div, link_tag, :class => "action")
  end
  
  def haiku_text_tag(options = {})
    options.reverse_merge!(
      :autocomplete => 'off',
      :rows => 3,
      :id => "haiku_text",
      :name => "haiku[text]",
      :class => "empty")

    text_area_tag(:text, "", options)
  end
  
  def haiku_summary_sentence(haiku)
    summary = []
    summary << "Subject: #{link_to_subject haiku.subject_name}" unless haiku.subject_name.nil?
    summary << "Group: #{link_to haiku.group.name, haiku.group}" unless haiku.group_id.nil?
    summary.join(', ')
  end
end