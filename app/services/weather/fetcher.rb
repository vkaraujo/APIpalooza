# frozen_string_literal: true

module Weather
  class Fetcher
    include HTTParty
    base_uri "https://api.openweathermap.org/data/2.5"

    def initialize(city)
      @city = city
    end

    def call
      return format_snapshot(snapshot) if snapshot.present?

      fetch_from_api || fallback_data
    end

    private

    def api_key
      ENV["OPENWEATHER_API_KEY"]
    end

    def snapshot
      @snapshot ||= WeatherSnapshot.find_by(city: @city)
    end

    def format_snapshot(snap)
      {
        "name" => snap.city,
        "main" => {
          "temp" => snap.temperature,
          "humidity" => snap.humidity
        },
        "weather" => [
          { "description" => snap.condition }
        ],
        "wind" => {
          "speed" => snap.wind_speed
        }
      }
    end

    def fetch_from_api
      response = self.class.get("/weather", query: {
        q: @city,
        appid: api_key,
        units: "metric"
      })

      return unless response.success?

      data = response.parsed_response
      save_snapshot(data)
      data
    rescue StandardError => e
      Rails.logger.error("🌩️ OpenWeather error: #{e.message}")
      nil
    end

    def save_snapshot(data)
      WeatherSnapshot.find_or_initialize_by(city: @city).update(
        temperature: data.dig("main", "temp"),
        condition: data.dig("weather", 0, "description"),
        humidity: data.dig("main", "humidity"),
        wind_speed: data.dig("wind", "speed"),
        fetched_at: Time.current
      )
    end

    def fallback_data
      {
        "name" => @city,
        "main" => { "temp" => "N/A", "humidity" => "N/A" },
        "weather" => [{ "description" => "Unavailable" }],
        "wind" => { "speed" => "N/A" }
      }
    end
  end
end
