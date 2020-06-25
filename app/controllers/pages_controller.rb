class PagesController < ApplicationController
  require 'json'
  require 'net/http'
  require 'open-uri'
  
  def home
    if params[:query].present?
      

      name = params[:query]
      @url = "https://api.openweathermap.org/data/2.5/weather?q=#{name.to_s}&appid=6665c7eaa20bb85d40242ced15d50d83"
      @uri = URI(@url)
      @response = Net::HTTP.get(@uri)
      @output = JSON.parse(@response)

      if @output.empty?
        @final_output = {"weather"=>[{"main"=>"N/A"}], "main"=>[{"temp"=>273, "humidity"=>"N/A"}] }
      elsif !@output
        @final_output = {"weather"=>[{"main"=>"N/A"}], "main"=>[{"temp"=>273, "humidity"=>"N/A"}] }
      else
        @final_output = @output
      end
    end  
  end

  def trello
  end  

  def beer
    @url = "https://sandbox-api.brewerydb.com/v2/beer/random/?key=76b511fd2a3a2643da15a48aae4c1bd0"
    

  end  

  private

  def request_api
  end  
end
