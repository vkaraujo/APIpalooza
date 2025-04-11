# frozen_string_literal: true

require 'rails_helper'

RSpec.describe YoutubeController, type: :request do
  describe 'POST /youtube' do
    let(:query) { 'rails tutorial' }

    context 'when query is blank' do
      it 'renders an error message' do
        post youtube_index_path, params: { query: '' }

        expect(response.body).to include('Search query cannot be blank.')
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when videos are found' do
      let(:videos) do
        [
          {
            title: 'Ruby on Rails Tutorial',
            video_id: 'abc123',
            thumbnail: 'https://example.com/thumb.jpg'
          }
        ]
      end

      before do
        allow(Youtube::Fetcher).to receive(:new).with(query).and_return(double(call: videos))
        post youtube_index_path, params: { query: query }
      end

      it 'renders the youtube/result partial' do
        expect(response.body).to include('Ruby on Rails Tutorial')
        expect(response.body).to include('abc123')
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when no videos are found' do
      before do
        allow(Youtube::Fetcher).to receive(:new).with(query).and_return(double(call: []))
        post youtube_index_path, params: { query: query }
      end

      it 'renders a no-results error message' do
        expect(response.body).to include('No results found for')
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
