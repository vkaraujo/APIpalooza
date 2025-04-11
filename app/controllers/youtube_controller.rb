# frozen_string_literal: true

class YoutubeController < ApplicationController
  def index; end

  def create
    query = params[:query].to_s.strip
    return render_error("Search query cannot be blank.") if query.blank?

    videos = Youtube::Fetcher.new(query).call

    if videos.any?
      render partial: "youtube/result", locals: { videos: videos, query: query }
    else
      render_error("No results found for “#{query}”")
    end
  end

  private

  def render_error(message)
    render turbo_stream: turbo_stream.replace(
      "youtube_result",
      "<div class='text-red-600'>#{message}</div>"
    )
  end
end
