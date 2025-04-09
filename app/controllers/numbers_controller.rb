# frozen_string_literal: true

class NumbersController < ApplicationController
  include HTTParty
  base_uri 'http://numbersapi.com'

  def index; end

  def create
    value = params[:value].to_s.strip
    type = params[:type] || 'trivia'

    fact = fetch_fact(value, type)

    if fact
      render partial: 'numbers/result', locals: { fact: fact }
    else
      render_error(value, type)
    end
  end

  private

  def fetch_fact(value, type)
    response = self.class.get("/#{value}/#{type}", query: { json: true })

    response.success? ? response.parsed_response['text'] : nil
  rescue StandardError => e
    Rails.logger.error("NumbersAPI error: #{e.message}")
    nil
  end

  def render_error(value, type)
    render turbo_stream: turbo_stream.replace(
      'numbers_result',
      "<div class='text-red-600'>Could not fetch a #{type} fact for “#{value}”.</div>"
    )
  end
end
