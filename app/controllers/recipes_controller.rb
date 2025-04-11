# frozen_string_literal: true

class RecipesController < ApplicationController
  def index; end

  def create
    keyword = params[:ingredient]

    detailed = Recipes::Fetcher.new(keyword).call

    if detailed
      render partial: 'recipes/results', locals: { data: detailed, keyword: keyword }
    else
      render_error(keyword)
    end
  end

  private

  def render_error(keyword)
    render turbo_stream: turbo_stream.replace(
      'recipes_result',
      "<div class='text-red-600'>Could not fetch recipes for #{keyword}.</div>"
    )
  end
end
