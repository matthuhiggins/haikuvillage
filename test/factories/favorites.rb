Factory.define :favorite do |f|
  f.association :author
  f.association :haiku
end