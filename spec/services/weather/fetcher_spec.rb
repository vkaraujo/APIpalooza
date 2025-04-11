# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Weather::Fetcher do
  let(:city) { 'Gotham' }
  let(:api_key) { 'fake-key' }
  let(:service) { described_class.new(city) }

  before do
    stub_const('ENV', ENV.to_h.merge('OPENWEATHER_API_KEY' => api_key))
    WeatherSnapshot.destroy_all
  end

  describe '#call' do
    context 'when a snapshot exists in the DB' do
      let!(:snapshot) do
        WeatherSnapshot.create!(
          city: city,
          temperature: 22.5,
          condition: 'cloudy',
          humidity: 60,
          wind_speed: 4.2,
          fetched_at: Time.current
        )
      end

      it 'returns the formatted snapshot' do
        result = service.call

        expect(result).to match(
          a_hash_including(
            'name' => city,
            'main' => {
              'temp' => 22.5,
              'humidity' => 60
            },
            'weather' => [a_hash_including('description' => 'cloudy')],
            'wind' => { 'speed' => 4.2 }
          )
        )
      end
    end

    context 'when no snapshot exists and API call succeeds' do
      let(:api_response) do
        {
          'main' => { 'temp' => 30.0, 'humidity' => 50 },
          'weather' => [{ 'description' => 'sunny' }],
          'wind' => { 'speed' => 3.5 },
          'name' => city
        }
      end

      before do
        stub_request(:get, 'https://api.openweathermap.org/data/2.5/weather')
          .with(query: { q: city, appid: api_key, units: 'metric' })
          .to_return(status: 200, body: api_response.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns the API data and stores it in the DB' do
        result = service.call

        expect(result['main']['temp']).to eq(30.0)
        expect(result['weather'].first['description']).to eq('sunny')

        snapshot = WeatherSnapshot.find_by(city: city)
        expect(snapshot).to have_attributes(
          temperature: 30.0,
          condition: 'sunny',
          humidity: 50,
          wind_speed: 3.5
        )
      end
    end

    context 'when API call fails' do
      before do
        stub_request(:get, 'https://api.openweathermap.org/data/2.5/weather')
          .with(query: { q: city, appid: api_key, units: 'metric' })
          .to_return(status: 500, body: 'error')
      end

      it 'returns fallback data' do
        result = service.call

        expect(result['main']['temp']).to eq('N/A')
        expect(result['weather'].first['description']).to eq('Unavailable')
        expect(result['wind']['speed']).to eq('N/A')
      end
    end
  end
end
