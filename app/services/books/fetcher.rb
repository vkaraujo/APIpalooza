# frozen_string_literal: true

module Books
  class Fetcher
    include HTTParty
    base_uri 'https://openlibrary.org'

    def initialize(query)
      @query = query
    end

    def call
      response = self.class.get('/search.json', query: { q: @query })
      return nil unless response.success?

      response.parsed_response['docs'].first(9)
    rescue StandardError => e
      Rails.logger.error("OpenLibrary error: #{e.message}")
      nil
    end
  end
end
