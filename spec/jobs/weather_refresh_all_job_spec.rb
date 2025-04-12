# frozen_string_literal: true

require "rails_helper"

RSpec.describe WeatherRefreshAllJob, type: :job do
  let!(:snapshot) { WeatherSnapshot.create(city: "London", temperature: 10, condition: "cloudy", humidity: 60, wind_speed: 5.0, fetched_at: 1.hour.ago) }
  let(:api_key) { ENV["OPENWEATHER_API_KEY"] }

  describe "#perform" do
    before do
      stub_const("ENV", ENV.to_h.merge("OPENWEATHER_API_KEY" => "test_key"))
    end

    context "when the API returns a successful response" do
      before do
        stub_request(:get, "https://api.openweathermap.org/data/2.5/weather")
          .with(query: { q: "London", appid: "test_key", units: "metric" })
          .to_return(
            status: 200,
            body: {
              main: { temp: 15.5, humidity: 72 },
              weather: [{ description: "clear sky" }],
              wind: { speed: 3.1 }
            }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "updates the weather snapshot" do
        expect {
          described_class.perform_now
          snapshot.reload
        }.to change { snapshot.temperature }.from(10).to(15.5)
         .and change { snapshot.condition }.from("cloudy").to("clear sky")
      end
    end

    context "when the API returns a non-success response" do
      before do
        stub_request(:get, "https://api.openweathermap.org/data/2.5/weather")
          .with(query: hash_including(q: "London"))
          .to_return(status: 500)
      end

      it "does not update the snapshot" do
        expect {
          described_class.perform_now
          snapshot.reload
        }.not_to change { snapshot.updated_at }
      end
    end

    context "when an exception occurs during the request" do
      before do
        stub_request(:get, "https://api.openweathermap.org/data/2.5/weather")
          .with(query: hash_including(q: "London"))
          .to_raise(StandardError.new("timeout"))
      end

      it "logs the error and continues" do
        expect(Rails.logger).to receive(:error).with(/❌ Error updating London: timeout/)
        described_class.perform_now
      end
    end
  end
end
