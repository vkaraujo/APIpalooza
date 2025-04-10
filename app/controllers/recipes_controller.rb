# frozen_string_literal: true

class RecipesController < ApplicationController
  include HTTParty
  base_uri 'https://api.spoonacular.com'

  def index; end

  def create
    keyword = params[:ingredient]
    recipes = search_recipes(keyword)

    if recipes
      detailed = fetch_detailed_recipes(recipes)
      render partial: 'recipes/results', locals: { data: detailed, keyword: keyword }
    else
      render_error(keyword)
    end
  end

  private

  def api_key
    ENV['SPOONACULAR_API_KEY']
  end

  def search_recipes(keyword)
    Rails.cache.fetch(["recipes_search", keyword.downcase], expires_in: 30.minutes) do
      response = self.class.get('/recipes/complexSearch',
                                headers: { 'x-api-key' => api_key },
                                query: { query: keyword, number: 6 })
      response.success? ? response.parsed_response['results'] : nil
    end
  end

  def fetch_detailed_recipes(recipes)
    recipes.map do |recipe|
      Rails.cache.fetch(["recipe_detail", recipe["id"]], expires_in: 2.hours) do
        response = self.class.get("/recipes/#{recipe['id']}/information",
                                  headers: { 'x-api-key' => api_key })

        response.success? ? response.parsed_response : fallback_recipe(recipe)
      end
    end
  end

  def fallback_recipe(recipe)
    { 'title' => recipe['title'], 'error' => true }
  end

  def render_error(keyword)
    render turbo_stream: turbo_stream.replace(
      'recipes_result',
      "<div class='text-red-600'>Could not fetch recipes for #{keyword}.</div>"
    )
  end
end
