namespace :haiku do
  namespace :counters do
    desc 'Roll the haiku counters forward'
    task :roll => :environment do
      ['view', 'favorited'].each do |metric|
        ['week', 'month'].each { |interval| clear_summary(metric, interval) }
      end
    end
    
    def clear_summary(metric, interval)
      weight = "#{interval_size(interval) - 1} / #{interval_size(interval)}"
      column = "#{metric}_count_#{interval}"
      
      Haiku.update_all("#{column} = #{column} * (#{weight})", "#{column} > 0")
    end
    
    def interval_size(interval)
      case interval
        when 'week' then 7
        when 'month' then 30
        else raise StandardError
      end
    end
  end
end