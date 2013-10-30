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
      msg = @server.gets
      pong(msg) if msg.include? "PING"
      respond if relevant?(msg.downcase)
    end
  end

  def pong(msg)
    @server.puts msg.gsub("PING", "PONG")
  end

  def connect
    @server = TCPSocket.open("chat.freenode.net", @port)
    @server.puts "USER #{@nick} 0 * #{@nick}"
    @server.puts "NICK #{@nick}"
    @server.puts "JOIN #{@channel}"
    #@server.puts "PRIVMSG #{@channel} :Message!" #intro greeting
  end

  def relevant?(msg)
    puts msg
    return false unless msg.include? "privmsg #{@channel} :"
    
    listening_for = ["cat"]
    listening_for.each do |keyword|
      return true if msg.include? keyword
    end
    return false
  end

  def respond
    response = "Hi!"
    @server.puts "PRIVMSG #{@channel} :#{response}"
  end

  def get_current_weather(city)
    url = "http://api.wunderground.com/api/ca74b375a5f317d5/conditions/q/Canada/#{city}.json"
    data = (JSON.parse Curl.get(url).body_str)["current_observation"]
    temperature = data["temp_c"]
    conditions = data["weather"].downcase
    feels_like = data["feelslike_c"]

    puts "It's #{temperature}°C in #{city} right now. Conditions are #{conditions} and it feels like #{feels_like}°C."
  end

  def get_forecast(city)
    url = "http://api.wunderground.com/api/ca74b375a5f317d5/forecast/q/Canada/#{city}.json"
    data = JSON.parse Curl.get(url).body_str
  end

end

Bot.new.get_current_weather("Ottawa")