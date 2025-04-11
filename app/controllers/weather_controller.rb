# frozen_string_literal: true

class WeatherController < ApplicationController
  def index; end

  def create
    city = params[:city].to_s.strip.titleize.presence || "São Paulo"

    data = Weather::Fetcher.new(city).call

    render partial: "weather/result", locals: { data: data }
  end
end
