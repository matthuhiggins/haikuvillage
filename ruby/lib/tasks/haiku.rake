namespace :haiku do
  namespace :counters do
    desc 'Clears the counters for the given INTERVAL: week, month'
    task :clear => :environment do
      clear_summaries ENV['INTERVAL']
    end
    
    desc 'Calculates the counters for the given INTERVAL'
    task :calculate do
      # no thanks?
    end
    
    def clear_summaries(interval)
      Haiku.update_all("view_count_#{interval} = 0", "view_count_#{interval} > 0")
      Haiku.update_all("favorited_count_#{interval} = 0", "favorited_count_#{interval} > 0")
    end
  end
end