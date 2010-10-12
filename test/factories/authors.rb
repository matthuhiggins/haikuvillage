Factory.define :author do |f|
  f.sequence(:username) { |n| "poopy#{n}" } 
  f.sequence(:email)    { |n| "author-#{n}@haikuvillage.com" } 
  f.password            'x'
end