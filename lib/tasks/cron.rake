task :cron => :environment do
  FlickrInspiration.collect
end