class WeatherController < ApplicationController
  include HTTParty
  base_uri "https://api.openweathermap.org/data/2.5"

  def index; end

  def create
    city = params[:city]
    weather_data = fetch_weather_for(city)

    if weather_data
      render partial: "weather/result", locals: { data: weather_data }
    else
      render turbo_stream: turbo_stream.replace("weather_result", "<div class='text-red-600'>Could not fetch weather for #{city}.</div>")
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

    unless response.success?
      Rails.logger.error("OpenWeather error: #{response.code} - #{response.message}")
      return nil
    end
  end
end
