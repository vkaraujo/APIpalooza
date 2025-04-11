# frozen_string_literal: true

class WeatherController < ApplicationController
  include HTTParty
  base_uri "https://api.openweathermap.org/data/2.5"

  def index; end

  def create
    city = params[:city].to_s.strip.titleize.presence || "São Paulo"
    snapshot = WeatherSnapshot.find_by(city: city)

    if snapshot
      Rails.logger.info("⚡ Using cached snapshot for #{city}")
      render partial: "weather/result", locals: { data: snapshot_to_api_format(snapshot) }
    else
      data = fetch_weather_for(city)
      save_weather_snapshot(city, data) if data

      render partial: "weather/result", locals: {
        data: data || fallback_data(city)
      }
    end
  end

  private

  def fetch_weather_for(city)
    response = self.class.get("/weather", query: {
      q: city,
      appid: api_key,
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
      humidity: data.dig("main", "humidity"),
      wind_speed: data.dig("wind", "speed"),
      fetched_at: Time.current
    )
  end

  def fallback_data(city)
    {
      "name" => city,
      "main" => { "temp" => "N/A", "humidity" => "N/A" },
      "weather" => [{ "description" => "Unavailable" }],
      "wind" => { "speed" => "N/A" }
    }
  end

  def api_key
    ENV["OPENWEATHER_API_KEY"]
  end

  def snapshot_to_api_format(snapshot)
    {
      "name" => snapshot.city,
      "main" => {
        "temp" => snapshot.temperature,
        "humidity" => snapshot.humidity
      },
      "weather" => [
        { "description" => snapshot.condition }
      ],
      "wind" => {
        "speed" => snapshot.wind_speed
      }
    }
  end
end
