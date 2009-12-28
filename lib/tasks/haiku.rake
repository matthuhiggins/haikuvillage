namespace :haiku do
  namespace :counters do    
    desc 'Roll the haiku counters forward'
    task :roll => :environment do
      counter_caches.each do |(klass, metrics)|
        metrics.each { |metric| roll_weekly(klass, metric) }
      end
    end
    
    def roll_weekly(klass, metric)
      column = "#{metric}_count_week"
      klass.update_all("#{column} = floor(#{column} * (6/7))", "#{column} > 0")
    end
    
    def counter_caches
      { Author  => ['haikus', 'favorited'], Subject => ['haikus'] }
    end
  end
  
  namespace :twitter do
    desc 'Upload haikus to twitter'
    task :update => :environment do
      begin
        haikus = Haiku.all(:conditions => {:twitter_status_id => nil}, :order => :id, :limit => 10)
        haikus.each { |haiku| Twitter.create_haiku(haiku) }
      end while haikus.size > 0
    end
  end
  
  namespace :inspirations do
    desc 'Delete inspirations that have no haikus, and create new ones'
    task :update => :environment do
      Conversation.delete_all :haikus_count_total => 0
      klasses.each &:collect
    end
    
    def klasses
      [FlickrInspiration]
    end
  end
end