# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Books::Fetcher do
  describe '#call' do
    let(:query) { 'Harry Potter' }
    let(:fetcher) { described_class.new(query) }

    context 'when the API responds successfully' do
      let(:response_body) do
        {
          'docs' => Array.new(10) { |i| { 'title' => "Book #{i + 1}" } }
        }.to_json
      end

      before do
        stub_request(:get, 'https://openlibrary.org/search.json')
          .with(query: { q: query })
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns the first 9 book results' do
        results = fetcher.call
        expect(results.size).to eq(9)
        expect(results.first['title']).to eq('Book 1')
      end
    end

    context 'when the API returns an error' do
      before do
        stub_request(:get, 'https://openlibrary.org/search.json')
          .with(query: { q: query })
          .to_return(status: 500)
      end

      it 'returns nil' do
        expect(fetcher.call).to be_nil
      end
    end

    context 'when an exception is raised' do
      before do
        allow(described_class).to receive(:get).and_raise(StandardError.new('Boom'))
      end

      it 'logs the error and returns nil' do
        expect(Rails.logger).to receive(:error).with(/OpenLibrary error: Boom/)
        expect(fetcher.call).to be_nil
      end
    end
  end
end
