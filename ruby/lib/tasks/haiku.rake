namespace :haiku do
  namespace :counters do
    desc 'Roll the haiku counters forward'
    task :roll => :environment do
      ['week', 'month'].each { |interval| clear_summaries interval }
    end
    
    def clear_summaries(interval)
      weight = "#{interval_size(interval) - 1} / #{interval_size(interval)}"
      
      Haiku.update_all("view_count_#{interval} = (#{weight})",
        "view_count_#{interval} > 0")
      
      Haiku.update_all("favorited_count_#{interval} = (#{weight})",
        "favorited_count_#{interval} > 0")
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