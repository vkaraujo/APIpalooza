# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JokesController, type: :request do
  describe 'POST /jokes' do
    let(:category) { 'Programming' }

    context 'when a joke is found' do
      let(:joke_data) { { 'type' => 'single', 'joke' => 'Why do programmers hate nature? It has too many bugs.' } }

      before do
        allow(Jokes::Fetcher).to receive(:fetch).with(category).and_return(joke_data)
        post jokes_path, params: { category: category }
      end

      it 'renders the jokes/result partial' do
        expect(response.body).to include('Why do programmers hate nature?')
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when no joke is found' do
      before do
        allow(Jokes::Fetcher).to receive(:fetch).with(category).and_return(nil)
        post jokes_path, params: { category: category }
      end

      it 'renders an error turbo stream' do
        expect(response.body).to include('Could not fetch a joke for')
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
