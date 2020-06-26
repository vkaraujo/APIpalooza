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
