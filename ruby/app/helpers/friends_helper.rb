module FriendsHelper
  # options:
  #  <tt>show_actions</tt> - Show add/remove friend and send message. Defaults to false
  def render_friends(friends, options = {})
    options.reverse_merge!(:show_actions => false)
    render :partial => "authors/friend", :collection => friends, :spacer_template => "conversations/divider", :locals => options
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