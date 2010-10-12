Factory.define :friendship do |f|
  f.association :author
  f.association :friend, factory: :author
end