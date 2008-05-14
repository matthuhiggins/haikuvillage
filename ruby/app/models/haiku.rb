class Haiku < ActiveRecord::Base
  VALID_SYLLABLES = [5, 7, 5]
  
  belongs_to :user, :counter_cache => true
  has_many :haiku_favorites, :dependent => :delete_all
  has_many :happy_users, :through => :haiku_favorites, :source => :user

  validates_presence_of :user_id
  validates_presence_of :text
  
  named_scope :recent, :order => 'haikus.id desc'
  named_scope :popular, :order => 'favorited_count_total desc', :conditions => "favorited_count_total > 0"
  
  before_create :twitter_update

  def validate    
    line_records = []
    text.each_line |line_text| { line_records << Line.new(line_text) }
    
    if line_records.length != VALID_SYLLABLES.size
      errors.add("Need three lines")
    else
      VALID_SYLLABLES.zip(line_records).each_with_index do |(expected, line_record), line_number|
        errors.add("line #{line_number}") unless expected == line_record.syllables
      end
    end
  end
  
  def twitter_update
    url = URI.parse('http://twitter.com/statuses/update.xml')
    request = Net::HTTP::Post.new(url.path)
    request.basic_auth user.username, user.password
    request.set_form_data({'status' => "@haikuvillage #{text}"}, ';')
    response = Net::HTTP.new(url.host, url.port).start {|http| http.request(request) }

    response.error! unless response.code[0..2].to_i == 200
    
    xml = XmlSimple.xml_in(response.body, 'keeproot' => false)
    self[:twitter_status_id] = xml['id'].to_i
  end
end