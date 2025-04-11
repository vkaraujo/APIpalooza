# frozen_string_literal: true

module Jokes
  class Fetcher
    include HTTParty
    base_uri 'https://v2.jokeapi.dev'

    def self.fetch(category)
      response = get("/joke/#{category}", query: { format: 'json' })

      response.success? ? response.parsed_response : nil
    rescue StandardError => e
      Rails.logger.error("JokeAPI error: #{e.message}")
      nil
    end
  end
end
