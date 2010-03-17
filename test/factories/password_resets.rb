Factory.define :password_reset do |f|
  f.login   { Factory(:author).username }
end