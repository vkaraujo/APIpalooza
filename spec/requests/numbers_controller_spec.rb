# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NumbersController, type: :request do
  describe 'POST /numbers' do
    let(:value) { '42' }
    let(:type) { 'trivia' }

    context 'when fact is found' do
      let(:fact) { '42 is the answer to life, the universe, and everything.' }

      before do
        allow(Numbers::FactFetcher).to receive(:new)
          .with(value: value, type: type)
          .and_return(double(call: fact))
      end

      it 'renders the numbers/result partial with fact' do
        post numbers_path, params: { value: value, type: type }

        expect(response.body).to include(fact)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when no fact is found' do
      before do
        allow(Numbers::FactFetcher).to receive(:new)
          .with(value: value, type: type)
          .and_return(double(call: nil))
      end

      it 'renders an error turbo stream' do
        post numbers_path, params: { value: value, type: type }

        expect(response.body).to include("Could not fetch a #{type} fact for “#{value}”.")
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'POST /numbers/surprise' do
    let(:fact) { '7 is a lucky number.' }

    before do
      allow(Numbers::FactFetcher).to receive(:new).and_return(double(call: fact))
    end

    it 'renders a random fact with a warning' do
      allow(Numbers::FactFetcher).to receive(:new).and_return(double(call: '7 is a lucky number.'))

      post surprise_numbers_path

      expect(response.body).to include('📘 Did you know?')
      expect(response.body).to include('7 is a lucky number.')
      expect(response.body).to match(%r{<strong>(trivia|math|year)</strong> fact about <strong>\d+</strong>})
    end

    context 'when no fact is found' do
      before do
        allow(Numbers::FactFetcher).to receive(:new).and_return(double(call: nil))
      end

      it 'renders an error turbo stream' do
        post surprise_numbers_path

        expect(response.body).to include('Could not fetch a')
      end
    end
  end
end
