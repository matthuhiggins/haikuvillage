namespace :haiku do
  namespace :counters do
    desc 'Roll the haiku counters forward'
    task :roll => :environment do
      { Haiku => ['view', 'favorited'], Author => ['haikus'] }.each do |(klass, metrics)|
        metrics.each { |metric| roll_weekly(klass, metric) }
      end
    end
    
    def roll_weekly(klass, metric)
      column = "#{metric}_count_week"
      klass.update_all("#{column} = floor(#{column} * (6/7))", "#{column} > 0")
    end
  end
end