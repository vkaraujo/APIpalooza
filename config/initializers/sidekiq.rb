require 'sidekiq'
require 'sidekiq-scheduler'

if Rails.env.development?
  Sidekiq.configure_server do |config|
    config.on(:startup) do
      schedule_file = Rails.root.join("config/sidekiq_schedule.yml")

      if File.exist?(schedule_file)
        Sidekiq::Scheduler.dynamic = false
        Sidekiq.schedule = YAML.load_file(schedule_file)
        Sidekiq::Scheduler.load_schedule!
      end
    end
  end
end
