module FriendsHelper
  # options:
  #  <tt>show_actions</tt> - Show add/remove friend and send message. Defaults to false
  def render_friends(friends, options = {})
    options.reverse_merge!(:show_actions => false)
    render :partial => "friends/friend", :collection => friends, :spacer_template => "conversations/divider", :locals => options
  end
  
  def update_friendship(friend)
    return unless current_author
    current_author.friends.include?(friend) ? remove_friend(friend) : add_friend(friend)
  end
  
  def add_friend(friend)
    link_to_remote("Add to friends",
      :url      => friend_url(friend.username),
      :method   => :put,
      :before   => "$('#{dom_id(friend)}').innerHTML = 'updating...'",
      :html     => {:id => dom_id(friend)})
  end

  def remove_friend(friend)
    link_to_remote("Remove from friends",
      :url      => friend_url(friend.username),
      :before   => "$('#{dom_id(friend)}').innerHTML = 'updating...'",
      :method   => :delete,
      :html     => {:id => dom_id(friend)})
  end
  
  def remove_friend_thumbnail(friend)
    link_to("Remove",
      friend_url(friend.username),
      {:method   => :delete, :confirm  => "Are you sure?"})
  end
end