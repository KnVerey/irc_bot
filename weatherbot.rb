require "socket"
require 'net/http'
require 'curb'
require "json"

class Bot

  def initialize
    @port = "6667"
    @nick = "WeatherBot"
    @channel = "#bitmakerlabs"
  end

  def run
    connect
    until @server.eof? do
      @msg = @server.gets
      pong if @msg.include? "PING"
      respond if relevant?
    end
  end

  def pong
    @server.puts @msg.gsub("PING", "PONG")
  end

  def connect
    @server = TCPSocket.open("chat.freenode.net", @port)
    @server.puts "USER #{@nick} 0 * #{@nick}"
    @server.puts "NICK #{@nick}"
    @server.puts "JOIN #{@channel}"
    @server.puts "PRIVMSG #{@channel} :Hi! If you enter 'weather' and a city (capitalized), I'll tell you the current weather."
  end

  def relevant?
    return false unless @msg.downcase.include? "privmsg #{@channel}".downcase
    (@msg.downcase.include? "weather") ? true : false
  end

  def respond
    @msg = @msg.gsub(/[:#]/," ")
    city = check_for_city
    give_current_weather(city)
  end

  def check_for_city
    msg_array = @msg.split(" ")
    city = msg_array.keep_if { |word| word.capitalize == word }

    city.length>=1 ? city=city.join("_") : city=nil
  end

  def give_current_weather(input_city)
    input_city==nil ? city="Toronto" : city=input_city

    url = "http://api.wunderground.com/api/ca74b375a5f317d5/conditions/q/Canada/#{city.capitalize}.json"

    data = (JSON.parse Curl.get(url).body_str)

    if data["current_observation"].nil?
      url = "http://api.wunderground.com/api/ca74b375a5f317d5/conditions/q/#{city.capitalize}.json"

      data = (JSON.parse Curl.get(url).body_str)

      if data["current_observation"].nil?
        if data["response"]["results"].nil? == false
          @server.puts "PRIVMSG #{@channel} :Sorry, there are too many cities with that name" 
        else
          @server.puts "PRIVMSG #{@channel} :Sorry, I couldn't find the weather for that city"
        end
        return
      end
    end

    temperature = data["current_observation"]["temp_c"]
    conditions = data["current_observation"]["weather"].downcase
    feels_like = data["current_observation"]["feelslike_c"]

    weather_msg = "It's #{temperature}°C in #{city.gsub("_", " ")} right now. Conditions are #{conditions} and it feels like #{feels_like}°C. (WeatherUnderground)"

    if input_city.nil?
      @server.puts "PRIVMSG #{@channel} :If you specified a city, I didn't understand. My default location is Toronto. " + weather_msg
    else 
      @server.puts "PRIVMSG #{@channel} :"+ weather_msg
    end
  end


end

Bot.new.run