namespace :weather do
  desc "Refresh all weather snapshots"
  task refresh_all: :environment do
    WeatherRefreshAllJob.new.perform
    puts "✅ Weather snapshots refreshed"
  end
end
