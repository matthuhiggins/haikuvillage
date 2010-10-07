Factory.define :author do |f|
  f.username          'poopy'
  f.sequence(:email)  { |n| "support-#{n}@haikuvillage.com" } 
  f.password          'x'
end