module AuthorsHelper
  def author_cloud(authors)
    font_sizes = {}
    authors.sort { |author1, author2| author1.favorited_count_total <=> author2.favorited_count_total }.each_with_index do |author, index|
      font_sizes[author.username] = number_to_percentage(80 + (120 * (index.to_f / authors.size)), :precision => 0)
    end
    
    sorted_by_name = authors.sort { |author1, author2| author1.username <=> author2.username }
    
    sorted_by_name.map do |author|
      link_to_author author, {:style => "font-size: #{font_sizes[author.username]}"}
    end.join(' ')
  end
  
  def render_friends(friends)
    render :partial => "authors/friend", :collection => friends, :spacer_template => "conversations/divider"
  end
  
  def author_list(authors)
    authors.map { |author| link_to_author author }.join(', ')
  end
  
  def link_to_author(author, html_options = {})
    link_to(author.username, author_url(author.username), html_options)
  end
  
  def update_friendship(friend)
    return unless current_author
    
    link = current_author.friends.include?(friend) ? remove_friend(friend) : add_friend(friend)
    content_tag(:div, link, :id => "update_friend")
  end
  
  def add_friend(friend)
    link_to_remote("Add to friends",
      :url      => author_friends_url(:author_id => friend.username),
      :method   => :post,
      :before   => "$('update_friend').innerHTML = 'updating...'",
      :update   => "update_friend")
  end

  def remove_friend(friend)
    link_to_remote("Remove from friends",
      :url      => {:controller => 'authors/friends', :author_id => friend.username, :action => "destroy"},
      :before   => "$('update_friend').innerHTML = 'updating...'",
      :method   => :delete,
      :update   => "update_friend")
  end
end