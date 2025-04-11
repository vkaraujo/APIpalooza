# frozen_string_literal: true

class JokesController < ApplicationController
  def index; end

  def create
    category = params[:category]
    joke = Jokes::Fetcher.fetch(category)

    if joke
      render partial: 'jokes/result', locals: { joke: joke }
    else
      render_error(category)
    end
  end

  private

  def render_error(category)
    render turbo_stream: turbo_stream.replace(
      'joke_result',
      "<div class='text-red-600'>Could not fetch a joke for “#{category}”.</div>"
    )
  end
end
