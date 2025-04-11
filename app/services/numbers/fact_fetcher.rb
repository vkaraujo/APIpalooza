# frozen_string_literal: true

module Numbers
  class FactFetcher
    include HTTParty
    base_uri 'http://numbersapi.com'

    def initialize(value:, type:)
      @value = value.to_s.strip
      @type = type.presence || "trivia"
    end

    def call
      response = self.class.get("/#{@value}/#{@type}", query: { json: true })
      response.success? ? response.parsed_response["text"] : nil
    rescue StandardError => e
      Rails.logger.error("NumbersAPI error: #{e.message}")
      nil
    end
  end
end
