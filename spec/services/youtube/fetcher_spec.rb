# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Youtube::Fetcher do
  describe '#call' do
    let(:query) { 'lofi music' }
    let(:api_key) { 'fake-api-key' }

    subject(:service) { described_class.new(query) }

    before do
      stub_const('ENV', ENV.to_h.merge('YOUTUBE_API_KEY' => api_key))
    end

    context 'when the API responds successfully' do
      let(:response_body) do
        {
          'items' => [
            {
              'id' => { 'videoId' => 'abc123' },
              'snippet' => {
                'title' => 'Lofi Beats',
                'thumbnails' => {
                  'medium' => { 'url' => 'https://img.youtube.com/vi/abc123/mqdefault.jpg' }
                }
              }
            }
          ]
        }.to_json
      end

      before do
        stub_request(:get, 'https://www.googleapis.com/youtube/v3/search')
          .with(query: {
            key: api_key,
            q: query,
            part: 'snippet',
            type: 'video',
            maxResults: 3
          })
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns an array of parsed video data' do
        result = service.call

        expect(result).to be_an(Array)
        expect(result.first[:title]).to eq('Lofi Beats')
        expect(result.first[:video_id]).to eq('abc123')
        expect(result.first[:thumbnail]).to include('youtube')
      end
    end

    context 'when the API request fails' do
      before do
        stub_request(:get, 'https://www.googleapis.com/youtube/v3/search')
          .with(query: hash_including(q: query))
          .to_return(status: 500)
      end

      it 'returns an empty array' do
        expect(service.call).to eq([])
      end
    end

    context 'when an exception occurs' do
      before do
        allow(Youtube::Fetcher).to receive(:get).and_raise(StandardError.new('network error'))
      end

      it 'logs the error and returns an empty array' do
        expect(Rails.logger).to receive(:error).with(/YouTube API exception: network error/)
        expect(service.call).to eq([])
      end
    end
  end
end
