require "socket"
require 'net/http'
require 'curb'
require "json"

class Bot

  def initialize
    @port = "6667"
    @nick = "Katbot"
    @channel = "#bitmakerlabs"
  end

  def run
    connect
    until @server.eof? do
      @msg = @server.gets.gsub(/[:#]/," ")
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
    #@server.puts "PRIVMSG #{@channel} :Message!" #intro greeting
  end

  def relevant?
    return false unless @msg.include? "privmsg #{@channel} :"
    (@msg.downcase.include? "weather") ? true : false
  end

  def respond
    city = check_for_city

    # if (@msg.include? "forecast") || (@msg.include? "tomorrow")
    #   give_forecast(city)
    # else
      give_current_weather(city)
    # end
  end

  def check_for_city
    city = @msg.split(" ").keep_if { |word| word.capitalize == word }
    puts city.to_s
    city.length==1 ? city=city[0] : city=nil
    puts city
    return city
  end

  def give_current_weather(input_city)
    input_city==nil ? city="Toronto" : city=input_city

    url = "http://api.wunderground.com/api/ca74b375a5f317d5/conditions/q/Canada/#{city.capitalize}.json"

    data = (JSON.parse Curl.get(url).body_str)

    if data.nil?
      url = "http://api.wunderground.com/api/ca74b375a5f317d5/conditions/q/#{city.capitalize}.json"

      data = (JSON.parse Curl.get(url).body_str)

      if data.nil? #still
        @server.puts "PRIVMSG #{@channel} :Sorry, I couldn't find the weather for that city"
        return
      end
    end

    temperature = data["current_observation"]["temp_c"]
    conditions = data["current_observation"]["weather"].downcase
    feels_like = data["current_observation"]["feelslike_c"]

    weather_msg = "It's #{temperature}°C in #{city} right now. Conditions are #{conditions} and it feels like #{feels_like}°C. (WeatherUnderground)"

    if input_city.nil?
      @server.puts "PRIVMSG #{@channel} :If you specified a city, I didn't understand. My default location is Toronto. " + weather_msg
    else 
      @server.puts "PRIVMSG #{@channel} :"+ weather_msg
    end

  end

  # def give_forecast(city)
  #   url = "http://api.wunderground.com/api/ca74b375a5f317d5/forecast/q/Canada/#{city}.json"
  #   data = JSON.parse Curl.get(url).body_str
  # end

end

# Bot.new.respond("weather Vancouver")
Bot.new.run