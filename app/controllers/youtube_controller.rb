# frozen_string_literal: true

class YoutubeController < ApplicationController
  include HTTParty
  base_uri "https://www.googleapis.com/youtube/v3"

  def index; end

  def create
    query = params[:query].to_s.strip
    return render_error("Search query cannot be blank.") if query.blank?

    videos = fetch_videos(query)

    if videos.any?
      render partial: "youtube/result", locals: { videos: videos, query: query }
    else
      render_error("No results found for “#{query}”")
    end
  end

  private

  def fetch_videos(query)
    response = self.class.get("/search", query: {
      key: ENV["YOUTUBE_API_KEY"],
      q: query,
      part: "snippet",
      type: "video",
      maxResults: 3
    })

    if response.success?
      response.parsed_response["items"].map do |item|
        {
          title: item.dig("snippet", "title"),
          video_id: item.dig("id", "videoId"),
          thumbnail: item.dig("snippet", "thumbnails", "medium", "url")
        }
      end
    else
      Rails.logger.error("YouTube API error: #{response.code} — #{response.body}")
      []
    end
  rescue StandardError => e
    Rails.logger.error("YouTube API exception: #{e.message}")
    []
  end

  def render_error(message)
    render turbo_stream: turbo_stream.replace(
      "youtube_result",
      "<div class='text-red-600'>#{message}</div>"
    )
  end
end
