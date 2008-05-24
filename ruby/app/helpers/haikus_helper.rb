module HaikusHelper
  def remote_login_form(&block)
    remote_form_for(:author,
      :before => update_page do |page|
        page.replace_html('haiku_login_message', 'Logging in...')
      end,
      :success    => update_page do |page|
        page.replace_html('haiku_login_message', 'Creating haiku...')
        page['haiku_form'].submit
      end,
      :failure    => update_page do |page|
        page.replace_html('haiku_login_message', 'Invalid username/password')
      end,
      :url        => login_url,
      :method     => :post,
      :html       => {:id => 'haiku_login', :style => 'display:none'},
      &block)
  end
end