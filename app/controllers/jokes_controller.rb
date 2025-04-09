# frozen_string_literal: true

class JokesController < ApplicationController
  include HTTParty
  base_uri 'https://v2.jokeapi.dev'

  def index; end

  def create
    category = params[:category]
    joke = fetch_joke(category)

    if joke
      render partial: 'jokes/result', locals: { joke: joke }
    else
      render_error(category)
    end
  end

  private

  def fetch_joke(category)
    response = self.class.get("/joke/#{category}", query: { format: 'json' })

    response.success? ? response.parsed_response : nil
  rescue StandardError => e
    Rails.logger.error("JokeAPI error: #{e.message}")
    nil
  end

  def render_error(category)
    render turbo_stream: turbo_stream.replace(
      'joke_result',
      "<div class='text-red-600'>Could not fetch a joke for “#{category}”.</div>"
    )
  end
end
