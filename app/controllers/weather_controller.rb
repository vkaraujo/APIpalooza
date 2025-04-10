# app/controllers/weather_controller.rb
class WeatherController < ApplicationController
  include HTTParty
  base_uri "https://api.openweathermap.org/data/2.5"

  def index; end

  def create
    city = params[:city].to_s.strip.titleize.presence || "São Paulo"
    snapshot = WeatherSnapshot.find_by(city: city)

    if snapshot
      Rails.logger.info("⚡ Using cached snapshot for #{city}")
      data = {
        "name" => snapshot.city,
        "main" => {
          "temp" => snapshot.temperature,
          "humidity" => 70 # optional, mock as needed
        },
        "weather" => [
          { "description" => snapshot.condition }
        ],
        "wind" => {
          "speed" => 3.2 # optional, mock as needed
        }
      }

      render partial: "weather/result", locals: { data: data }
    else
      data = fetch_weather_for(city)
      save_weather_snapshot(city, data) if data
      render partial: "weather/result", locals: { data: data || { "name" => city, "main" => { "temp" => "N/A" }, "weather" => [{ "description" => "Unavailable" }], "wind" => { "speed" => "N/A" } } }
    end
  end

  private

  def fetch_weather_for(city)
    response = self.class.get("/weather", query: {
      q: city,
      appid: ENV["OPENWEATHER_API_KEY"],
      units: "metric"
    })

    return response.parsed_response if response.success?

    Rails.logger.error("OpenWeather error: #{response.code} - #{response.message}")
    nil
  end

  def save_weather_snapshot(city, data)
    snapshot = WeatherSnapshot.find_or_initialize_by(city: city)
    snapshot.update(
      temperature: data.dig("main", "temp"),
      condition: data.dig("weather", 0, "description"),
      fetched_at: Time.current
    )
  end
end
