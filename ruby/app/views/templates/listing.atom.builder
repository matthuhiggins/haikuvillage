atom_feed() do |feed|
  feed.title(@title)
  feed.updated((@haikus.first.created_at))

  for haiku in @haikus
    feed.entry(haiku) do |entry|
      entry.title(haiku.text.gsub(/\n/, '/ '))
      entry.content(haiku.text, :type => 'text')
      entry.author do |author|
        author.name
      end
    end
  end
end
