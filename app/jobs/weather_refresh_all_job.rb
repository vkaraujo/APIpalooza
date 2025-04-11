# frozen_string_literal: true

class WeatherRefreshAllJob < ApplicationJob
  queue_as :default

  def perform
    WeatherSnapshot.find_each do |snapshot|
      update_weather(snapshot)
    end
  end

  private

  def update_weather(snapshot)
    response = fetch_weather(snapshot.city)
    return unless response.success?

    parsed_data = parse_weather_data(response)
    apply_update(snapshot, parsed_data)
  rescue StandardError => e
    Rails.logger.error("❌ Error updating #{snapshot.city}: #{e.message}")
  end

  def fetch_weather(city)
    HTTParty.get("https://api.openweathermap.org/data/2.5/weather", query: {
      q: city,
      appid: ENV["OPENWEATHER_API_KEY"],
      units: "metric"
    })
  end

  def parse_weather_data(response)
    response.parsed_response
  end

  def apply_update(snapshot, data)
    snapshot.update(
      temperature: data.dig("main", "temp"),
      condition: data.dig("weather", 0, "description"),
      humidity: data.dig("main", "humidity"),
      wind_speed: data.dig("wind", "speed"),
      fetched_at: Time.current
    )
  end
end
