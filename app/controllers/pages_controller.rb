class PagesController < ApplicationController
  def home
  end

  def search
    cities = find_city(params[:city])
    unless countries
      flash[:alert] = 'City not found'
      return render action: :home
    end

     @city = cities.first
     @weather = find_weather(@final_output['weather'][0]['main'])

  end  

  private

  def request_api(url)
    require 'open-uri'
    require 'json'
    require 'net/http'

    @uri = URI(@url)
    @response = Net::HTTP.get(@uri)
    @output = JSON.parse(@response)

    if @output.empty?
      @final_output = "Error"
    elsif !@output
      @final_output = "Error"
    else
      @final_output = @output
    end
  end

  def find_city(name)
    request_api(
      "https://api.openweathermap.org/data/2.5/weather?q=#{name}&appid=6665c7eaa20bb85d40242ced15d50d83"
    )
  end
end
