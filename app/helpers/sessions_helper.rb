module SessionsHelper
  def facebook_login(options = {})
    content = options.delete(:name) || "Login"
    options.reverse_merge! class: "fb-login-button", scope: "email", onlogin: "location.reload();"
    content_tag(:div, content, options)
  end
end