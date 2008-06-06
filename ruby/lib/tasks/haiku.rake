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
      { Haiku   => ['view', 'favorited'], Author  => ['haikus'], Subject => ['haikus'] }
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
  
  namespace :cache do
    desc 'Clear eveything that has been cached'
    task :clear => :environment do
      ActionController::Base.cache_store.clear
    end
  end
end