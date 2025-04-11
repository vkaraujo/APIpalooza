# frozen_string_literal: true

require 'rails_helper'
require 'cgi'

RSpec.describe TriviaController, type: :request do
  describe 'POST /trivia' do
    let(:difficulty) { 'easy' }
    let(:qtype) { 'multiple' }

    context 'when API returns a valid question' do
      let(:api_response) do
        {
          'response_code' => 0,
          'results' => [
            {
              'category' => 'General Knowledge',
              'type' => 'multiple',
              'difficulty' => 'easy',
              'question' => CGI.escape('What is the capital of France?'),
              'correct_answer' => CGI.escape('Paris'),
              'incorrect_answers' => [
                CGI.escape('London'),
                CGI.escape('Berlin'),
                CGI.escape('Madrid')
              ]
            }
          ]
        }
      end

      before do
        allow(TriviaController).to receive(:get).and_return(
          double(success?: true, parsed_response: api_response, code: 200, body: api_response.to_json)
        )

        post trivia_path, params: { difficulty: 'Easy', qtype: 'Multiple Choice' }
      end

      it 'renders the trivia/result partial' do
        expect(response.body).to include('Paris')
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when API fails' do
      before do
        allow(TriviaController).to receive(:get).and_return(
          double(success?: false, parsed_response: {}, code: 500, body: '')
        )

        post trivia_path, params: { difficulty: 'Easy', qtype: 'Multiple Choice' }
      end

      it 'renders an error message' do
        expect(response.body).to include(CGI.escapeHTML("Couldn't get a new multiple question (easy)"))
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'POST /trivia/check' do
    it 'renders feedback with correct or incorrect info' do
      post check_trivia_path, params: {
        question: 'What is 2+2?',
        answer: '4',
        correct_answer: '4'
      }

      expect(response.body).to include('What is 2+2?')
      expect(response.body).to include('4')
    end
  end
end
