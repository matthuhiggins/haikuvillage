class HaikuView
  attr_accessor :lines, :title, :db_haiku
  
  def initialize(title="", text="")
    @title = title
    @lines = []
    self.haiku_text= text
  end
    
  def haiku_text
    @haikutext
  end
  
  def haiku_text=(text)
    @haikutext = text
    @lines = []
    text.each_line {|line| @lines << Line.new(line) }
  end
  
  def self.from_haiku(haiku)
    hv = self.new
    hv.db_haiku = haiku
    hv.title = haiku.title
    #hv.haiku_text= [ haiku.line1, haiku.line2, haiku.line3 ].join("\n")
    hv.lines = [ haiku.line1, haiku.line2, haiku.line3 ].map {|line| Line.new(line)}
    hv
  end
end