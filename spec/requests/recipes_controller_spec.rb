# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecipesController, type: :request do
  describe 'POST /recipes' do
    let(:keyword) { 'chicken' }

    context 'when fetcher returns data' do
      let(:fake_data) do
        [
          { 'title' => 'Grilled Chicken', 'id' => 123, 'image' => 'chicken.jpg' }
        ]
      end

      before do
        allow(Recipes::Fetcher).to receive(:new).with(keyword).and_return(double(call: fake_data))
      end

      it 'renders the recipes/results partial with data and keyword' do
        post recipes_path, params: { ingredient: keyword }

        expect(response.body).to include('Grilled Chicken')
        expect(response.body).to include('chicken.jpg')
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when fetcher returns nil' do
      before do
        allow(Recipes::Fetcher).to receive(:new).with(keyword).and_return(double(call: nil))
      end

      it 'renders an error turbo stream' do
        post recipes_path, params: { ingredient: keyword }

        expect(response.body).to include("Could not fetch recipes for #{keyword}")
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
