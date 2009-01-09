atom_feed do |feed|
  feed.title(@title)
  feed.updated((@haikus.first.created_at))

  @haikus.each do |haiku|
    feed.entry(haiku) do |entry|
      entry.title(haiku.terse)
      entry.content(haiku.text, :type => 'text')
      entry.author do |author|
        author.name(haiku.author.username)
      end
    end
  end
end