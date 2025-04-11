# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Recipes::Fetcher do
  let(:keyword) { 'pasta' }
  let(:api_key) { 'fake-key' }
  let(:basic_recipe) { { 'id' => 123, 'title' => 'Spaghetti' } }
  let(:detailed_recipe) { { 'title' => 'Spaghetti', 'instructions' => 'Boil water...' } }

  subject(:service) { described_class.new(keyword) }

  before do
    stub_const('ENV', ENV.to_h.merge('SPOONACULAR_API_KEY' => api_key))
    Rails.cache.clear
  end

  describe '#call' do
    context 'when both API calls are successful' do
      before do
        stub_request(:get, 'https://api.spoonacular.com/recipes/complexSearch')
          .with(query: { query: keyword, number: 6 }, headers: { 'x-api-key' => api_key })
          .to_return(status: 200, body: { results: [basic_recipe] }.to_json, headers: { 'Content-Type' => 'application/json' })

        stub_request(:get, 'https://api.spoonacular.com/recipes/123/information')
          .with(headers: { 'x-api-key' => api_key })
          .to_return(status: 200, body: detailed_recipe.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns detailed recipes' do
        result = service.call
        expect(result).to be_an(Array)
        expect(result.first['title']).to eq('Spaghetti')
        expect(result.first['instructions']).to eq('Boil water...')
      end
    end

    context 'when basic recipe fetch fails' do
      before do
        stub_request(:get, 'https://api.spoonacular.com/recipes/complexSearch')
          .with(query: { query: keyword, number: 6 }, headers: { 'x-api-key' => api_key })
          .to_return(status: 500)
      end

      it 'returns nil' do
        expect(service.call).to be_nil
      end
    end

    context 'when detail recipe fetch fails' do
      before do
        stub_request(:get, 'https://api.spoonacular.com/recipes/complexSearch')
          .with(query: { query: keyword, number: 6 }, headers: { 'x-api-key' => api_key })
          .to_return(
            status: 200,
            body: { results: [basic_recipe] }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        stub_request(:get, 'https://api.spoonacular.com/recipes/123/information')
          .with(headers: { 'x-api-key' => api_key })
          .to_return(status: 500)
      end

      it 'returns a fallback recipe' do
        result = service.call
        expect(result.first['title']).to eq('Spaghetti')
        expect(result.first['error']).to be true
      end
    end
  end
end
