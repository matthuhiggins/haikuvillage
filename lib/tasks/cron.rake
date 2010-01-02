task :cron => :environment do
  def roll_weekly(model, column)
    model.update_all("#{column} = floor(#{column} * (6/7))", "#{column} > 0")
  end

  Conversation.delete_all :haikus_count_total => 0
  FlickrInspiration.collect
  
  roll_weekly Author, 'haikus_count_week'
  roll_weekly Author, 'favorited_count_week'
  roll_weekly Subject, 'haikus_count_week'
end