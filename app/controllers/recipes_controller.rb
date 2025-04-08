# frozen_string_literal: true

class RecipesController < ApplicationController
  include HTTParty
  base_uri 'https://api.spoonacular.com'

  def index; end

  def show
    keyword = params[:ingredient]
    response = self.class.get("/recipes/complexSearch", 
      headers: { "x-api-key" => ENV["SPOONACULAR_API_KEY"] },
      query: { query: keyword, number: 5 }
    )

    Rails.logger.debug "Spoonacular key from ENV: #{ENV['SPOONACULAR_API_KEY']}"
    Rails.logger.debug "Loaded API key: #{ENV['SPOONACULAR_API_KEY']}"
    Rails.logger.debug "Spoonacular status: #{response.code}"
    Rails.logger.debug "Spoonacular body: #{response.body}"

    if response.success?
      render partial: 'recipes/results', locals: { data: response.parsed_response['results'], keyword: keyword }
    else
      render turbo_stream: turbo_stream.replace('recipes_result', "<div class='text-red-600'>Could not fetch recipes for #{keyword}.</div>")
    end
  end
end
