# frozen_string_literal: true

module Youtube
  class Fetcher
    include HTTParty
    base_uri "https://www.googleapis.com/youtube/v3"

    def initialize(query)
      @query = query
    end

    def call
      fetch_videos
    end

    private

    def fetch_videos
      response = self.class.get("/search", query: {
        key: ENV["YOUTUBE_API_KEY"],
        q: @query,
        part: "snippet",
        type: "video",
        maxResults: 3
      })

      return parse_response(response) if response.success?

      Rails.logger.error("YouTube API error: #{response.code} — #{response.body}")
      []
    rescue StandardError => e
      Rails.logger.error("YouTube API exception: #{e.message}")
      []
    end

    def parse_response(response)
      response.parsed_response["items"].map do |item|
        {
          title: item.dig("snippet", "title"),
          video_id: item.dig("id", "videoId"),
          thumbnail: item.dig("snippet", "thumbnails", "medium", "url")
        }
      end
    end
  end
end
