# frozen_string_literal: true

class TriviaController < ApplicationController
  attr_reader :last_response_code, :last_response_body

  LAST_TRIVIA_CALL_KEY = "trivia_api_last_call_at"
  RATE_LIMITED_MESSAGE = '⏳ Slow down, trivia master! The API we use only allows one question every 5 seconds. Please wait a moment and try again.'

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
      rate_limited = @rate_limited_skipped || last_response_code == 429 || response_code_5?
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
    return rate_limited_response if rate_limited?

    response = make_trivia_request(difficulty, qtype)
    store_response_data(response)

    return nil unless valid_response?(response)

    cache_last_call_time
    decode_question_params(response.parsed_response["results"].first)
  rescue StandardError => e
    Rails.logger.error("Trivia API error: #{e.message}")
    nil
  end

  def decode_question_params(raw_question)
    raw_question.transform_values do |value|
      case value
      when String
        CGI.unescape(value)
      when Array
        value.map { |element| CGI.unescape(element) }
      else
        value
      end
    end
  end

  def response_code_5?
    return false unless last_response_body.present?

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
      RATE_LIMITED_MESSAGE
    else
      "😓 Couldn't get a new #{qtype} question (#{difficulty}). Try again or change the settings."
    end
  end

  def rate_limited?
    @last_trivia_call = Rails.cache.read(LAST_TRIVIA_CALL_KEY)
    @last_trivia_call && Time.current - @last_trivia_call < 5.seconds
  end

  def rate_limited_response
    Rails.logger.info("🚫 Trivia API request skipped — last call was too recent")
    @rate_limited_skipped = true
    nil
  end

  def make_trivia_request(difficulty, qtype)
    self.class.get("/api.php", query: {
      amount: 1,
      difficulty: difficulty,
      type: qtype,
      encode: "url3986"
    })
  end

  def store_response_data(response)
    @last_response_code = response.code
    @last_response_body = response.body
  end

  def valid_response?(response)
    response.success? && response.parsed_response["results"].any?
  end

  def cache_last_call_time
    Rails.cache.write(LAST_TRIVIA_CALL_KEY, Time.current, expires_in: 10.seconds)
  end
end
