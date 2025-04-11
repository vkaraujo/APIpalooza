# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Jokes::Fetcher do
  describe '.fetch' do
    let(:category) { 'Programming' }

    context 'when the API responds successfully' do
      let(:response_body) do
        {
          'type' => 'single',
          'joke' => 'Why do programmers prefer dark mode? Because light attracts bugs!'
        }.to_json
      end

      before do
        stub_request(:get, "https://v2.jokeapi.dev/joke/#{category}")
          .with(query: { format: 'json' })
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns the parsed joke' do
        result = described_class.fetch(category)
        expect(result['joke']).to include('dark mode')
      end
    end

    context 'when the API request fails' do
      before do
        stub_request(:get, "https://v2.jokeapi.dev/joke/#{category}")
          .with(query: { format: 'json' })
          .to_return(status: 500)
      end

      it 'returns nil' do
        expect(described_class.fetch(category)).to be_nil
      end
    end

    context 'when an exception is raised' do
      before do
        allow(described_class).to receive(:get).and_raise(StandardError.new('oops'))
      end

      it 'logs the error and returns nil' do
        expect(Rails.logger).to receive(:error).with(/JokeAPI error: oops/)
        expect(described_class.fetch(category)).to be_nil
      end
    end
  end
end
