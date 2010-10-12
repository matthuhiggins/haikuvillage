Factory.define :message do |f|
  f.association :author
  f.association :sender, factory: :author
  f.association :recipient, factory: :author
  f.text        "77\n155\n77"
  f.unread      true
end