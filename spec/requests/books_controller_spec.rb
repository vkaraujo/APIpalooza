# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BooksController, type: :request do
  describe 'POST /books' do
    let(:query) { 'ruby programming' }

    context 'when books are found' do
      let(:books_data) do
        [
          { 'title' => 'Programming Ruby', 'author_name' => ['Dave Thomas'] },
          { 'title' => 'Eloquent Ruby', 'author_name' => ['Russ Olsen'] }
        ]
      end

      before do
        allow(Books::Fetcher).to receive(:new).with(query).and_return(double(call: books_data))
        post books_path, params: { query: query }
      end

      it 'renders the books/results partial' do
        expect(response.body).to include('Programming Ruby')
        expect(response.body).to include('Eloquent Ruby')
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when no books are found' do
      before do
        allow(Books::Fetcher).to receive(:new).with(query).and_return(double(call: nil))
        post books_path, params: { query: query }
      end

      it 'renders an error turbo stream' do
        expect(response.body).to include('Could not fetch books for')
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
