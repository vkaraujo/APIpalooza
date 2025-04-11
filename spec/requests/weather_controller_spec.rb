# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeatherController, type: :request do
  describe 'POST /weather' do
    let(:city) { 'Rio De Janeiro' }
    let(:fake_data) do
      {
        'name' => city,
        'main' => { 'temp' => 30.0, 'humidity' => 70 },
        'weather' => [{ 'description' => 'clear sky' }],
        'wind' => { 'speed' => 3.0 }
      }
    end

    before do
      allow(Weather::Fetcher).to receive(:new).with(city).and_return(double(call: fake_data))
    end

    it 'renders the weather/result partial with fetched data' do
      post weather_index_path, params: { city: city }

      expect(response).to be_successful
      expect(response.body).to include("Weather in #{city}")
      expect(response.body).to include('30.0°C')
    end
  end
end
