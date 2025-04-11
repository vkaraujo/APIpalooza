# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Numbers::FactFetcher do
  describe '#call' do
    let(:value) { '42' }
    let(:type) { 'trivia' }

    context 'when the API responds successfully' do
      let(:response_body) { { 'text' => '42 is the answer to life.' }.to_json }

      before do
        stub_request(:get, "http://numbersapi.com/#{value}/#{type}")
          .with(query: { json: true })
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns the fact text' do
        fact = described_class.new(value: value, type: type).call
        expect(fact).to eq('42 is the answer to life.')
      end
    end

    context 'when the API request fails' do
      before do
        stub_request(:get, "http://numbersapi.com/#{value}/#{type}")
          .with(query: { json: true })
          .to_return(status: 500, body: '')
      end

      it 'returns nil' do
        fact = described_class.new(value: value, type: type).call
        expect(fact).to be_nil
      end
    end

    context 'when an exception occurs' do
      before do
        allow(described_class).to receive(:get).and_raise(StandardError.new('something went wrong'))
      end

      it 'logs the error and returns nil' do
        expect(Rails.logger).to receive(:error).with(/NumbersAPI error: something went wrong/)
        fact = described_class.new(value: value, type: type).call
        expect(fact).to be_nil
      end
    end
  end
end
