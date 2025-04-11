# frozen_string_literal: true

module Recipes
  class Fetcher
    include HTTParty
    base_uri 'https://api.spoonacular.com'

    def initialize(keyword)
      @keyword = keyword.to_s.strip
      @api_key = ENV['SPOONACULAR_API_KEY']
    end

    def call
      basic_recipes = fetch_basic_recipes
      return nil unless basic_recipes

      fetch_details_for(basic_recipes)
    end

    private

    def fetch_basic_recipes
      Rails.cache.fetch(["recipes_search", @keyword.downcase], expires_in: 30.minutes) do
        response = self.class.get('/recipes/complexSearch',
          headers: { 'x-api-key' => @api_key },
          query: { query: @keyword, number: 6 }
        )

        response.success? ? response.parsed_response['results'] : nil
      end
    end

    def fetch_details_for(recipes)
      recipes.map do |recipe|
        Rails.cache.fetch(["recipe_detail", recipe["id"]], expires_in: 2.hours) do
          response = self.class.get("/recipes/#{recipe['id']}/information",
            headers: { 'x-api-key' => @api_key }
          )

          response.success? ? response.parsed_response : fallback(recipe)
        end
      end
    end

    def fallback(recipe)
      { 'title' => recipe['title'], 'error' => true }
    end
  end
end
