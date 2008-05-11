module HaikusHelper
  def remote_login_form(&block)
    remote_form_for(:user,
      :before => "$('user_submit').hide()",
      :complete => "$('user_submit').show()",
      :success => "$('haiku_form').submit();",
      :failure => "$('error_box').innerHTML = 'bad login'",
      :url => login_url,
      :method => :post,
      :html => {:id => 'haiku_login', :style => 'display:none'},
      &block)
  end
end