atom_feed do |feed|
  feed.title("Haikus by " + @author.username)
  feed.updated(@haikus.first.created_at)

  for haiku in @haikus
    feed.entry(haiku) do |entry|
      entry.title(haiku.terse)
      entry.content(haiku.text, :type => 'text')
      entry.author do |author|
        author.name(@author.username)
      end
    end
  end
end
