class PagesController < ApplicationController
  require 'json'
  require 'net/http'
  require 'open-uri'
  
  def home
  end

  def trello
  end 

  def youtube
  end
  
  def food
    if params[:query].present?
      
      name = params[:query]
      @url = "https://api.spoonacular.com/recipes/search?apiKey=1b05aab005a14beb899dd8e0fb8d4cb9&query=#{name.to_s}&number=3"
      @uri = URI(@url)
      @response = Net::HTTP.get(@uri)
      @output = JSON.parse(@response)

      if @output.empty?
        @title_output = "Error"
        @img_output = "Error"
        @title_outputb = "Error"
        @img_outputb = "Error"
        @title_outputc = "Error"
        @img_outputc = "Error"
      elsif !@output
        @title_output = "Error"
        @img__output = "Error"
        @title_outputb = "Error"
        @img_outputb = "Error"
        @title_outputc = "Error"
        @img_outputc = "Error"
      else
        @title_output = @output['results'][0]['title']
        @img_output = @output['results'][0]['id']

        @title_outputb = @output['results'][1]['title']
        @img_outputb = @output['results'][1]['id']

        @title_outputc = @output['results'][2]['title']
        @img_outputc = @output['results'][2]['id']

      end
    end  
  end  


  def weather
    if params[:query].present?
      
      name = params[:query]
      @url = "https://api.openweathermap.org/data/2.5/weather?q=#{name.to_s}&appid=6665c7eaa20bb85d40242ced15d50d83"
      @uri = URI(@url)
      @response = Net::HTTP.get(@uri)
      @output = JSON.parse(@response)

      if @output.empty?
        @name_output = "Error"
        @weather_output = "Error"
        @temp_output = "Error"
        @humidity_output = "Error"
      elsif !@output
        @name_output = "Error"
        @weather_output = "Error"
        @temp_output = "Error"
        @humidity_output = "Error"
      else
        @name_output = @output['name']
        @weather_output = @output['weather'][0]['main']
        @temp_output = @output['main']['temp']
        @humidity_output = @output['main']['humidity']
      end
    end  
  end

  private

  def request_api
  end  
end
