# frozen_string_literal: true

class TriviaController < ApplicationController
  attr_reader :last_response_code, :last_response_body

  include HTTParty
  base_uri 'https://opentdb.com'

  def index; end

  def create
    difficulty = (params[:difficulty] || 'Easy').downcase
    qtype = normalize_qtype(params[:qtype])

    question = fetch_question(difficulty, qtype)

    if question
      render partial: 'trivia/result', locals: { question: question }
    else
      rate_limited = last_response_code == 429 || response_code_5?
      render_error(difficulty, qtype, rate_limited: rate_limited)
    end
  end

  def check
    render_feedback(
      question: params[:question],
      chosen: params[:answer],
      correct: params[:correct_answer]
    )
  end

  private

  def normalize_qtype(type)
    return 'multiple' if type == 'Multiple Choice'
    return 'boolean' if type == 'True or False'

    'multiple'
  end

  def fetch_question(difficulty, qtype)
    response = self.class.get('/api.php', query: {
      amount: 1,
      difficulty: difficulty,
      type: qtype,
      encode: 'url3986'
    })

    @last_response_code = response.code
    @last_response_body = response.body

    parsed = response.parsed_response
    return nil unless response.success? && parsed['results'].any?

    decode_question(parsed['results'].first)
  rescue StandardError => e
    Rails.logger.error("TriviaAPI error: #{e.message}")
    nil
  end

  def decode_question(q)
    q.transform_values do |v|
      case v
      when String then CGI.unescape(v)
      when Array then v.map { |s| CGI.unescape(s) }
      else v
      end
    end
  end

  def response_code_5?
    parsed = JSON.parse(last_response_body)
    parsed['response_code'] == 5
  rescue JSON::ParserError, NoMethodError
    false
  end

  def render_feedback(question:, chosen:, correct:)
    render turbo_stream: turbo_stream.replace(
      'trivia_result',
      ApplicationController.render(
        partial: 'trivia/feedback',
        locals: {
          question: question,
          correct: correct,
          chosen: chosen,
          is_correct: chosen == correct
        }
      )
    )
  end

  def render_error(difficulty, qtype, rate_limited: false)
    message = build_error_message(difficulty, qtype, rate_limited)

    html = ApplicationController.render(inline: <<-ERB, locals: { message: message })
      <div class='text-red-600'>
        <%= message %>
        <div class="mt-4">
          <%= link_to "🔁 Try again", trivia_path, class: "inline-block px-4 py-2 bg-indigo-600 text-white rounded hover:bg-indigo-700" %>
        </div>
      </div>
    ERB

    render turbo_stream: turbo_stream.replace('trivia_result', html)
  end

  def build_error_message(difficulty, qtype, rate_limited)
    if rate_limited
      '⚠️ Too many requests! Please wait a few seconds and try again.'
    else
      "😓 Couldn't get a new #{qtype} question (#{difficulty}). Try again or change the settings."
    end
  end
end
