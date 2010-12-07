module HaikusHelper
  # options include:
  #   conversing_with - The haiku that this creation is in reference too
  #   conversation - An existing conversation that this haiku is being added to
  #   inspire - Show the inspiration upload/image options
  def render_create(options = {})
    render :partial => "haikus/create", :locals => options
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
  
  def haiku_text_tag(options = {})
    options.reverse_merge!(
      autocomplete: 'off',
      rows: 3,
      id: "haiku_text",
      name: "haiku[text]",
      class: "empty")

    text_area_tag(:text, "", options)
  end  
end