module FriendsHelper
  # options:
  #  <tt>show_actions</tt> - Show add/remove friend and send message. Defaults to false
  def render_friends(friends, options = {})
    options.reverse_merge!(:show_actions => false)
    render :partial => "friends/friend", :collection => friends, :spacer_template => "conversations/divider", :locals => options
  end
  
  def add_friend(friend)
    options = {method: :put, id: 'add-friend', remote: true}
    options[:style] = 'display:none;' if current_author.following.include?(friend)
    button_to("+ Follow", friend_path(friend.username), options)
  end

  def remove_friend(friend)
    options = {method: :delete, id: 'remove-friend', remote: true}
    options[:style] = 'display:none;' unless current_author.following.include?(friend)
    button_to("Following", friend_path(friend.username), options)
  end
  
  def remove_friend_thumbnail(friend)
    link_to("Remove",
      friend_path(friend.username),
      {:method   => :delete, :confirm  => "Are you sure?"})
  end
end