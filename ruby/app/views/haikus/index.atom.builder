atom_feed do |feed|
  feed.title(@title)
  feed.updated((@haikus.first.created_at))

  @haikus.each do |haiku|
    feed.entry(haiku, :url => haiku_path(haiku, :format => nil) ) do |entry|
      entry.title(haiku.terse)
      entry.content :type => :xhtml do |xhtml|
        if haiku.conversation && haiku.conversation.inspiration
          xhtml.img(:src => haiku.conversation.inspiration.thumbnail)
        end
        
        haiku.text.each_line do |line|
          xhtml.p(line, :style => "font-size: 18pt")
        end
        
        byline = haiku.author.username
        byline += " about #{haiku.subject_name}" unless haiku.subject_name.nil?
        xhtml.i byline
      end
      entry.author do |author|
        author.name(haiku.author.username)
      end
    end
  end
end