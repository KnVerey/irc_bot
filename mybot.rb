require "socket"

class Bot

  def initialize
    @server = "chat.freenode.net"
    @port = "6667"
    @nick = "Katbot"
    @channel = "#bitmakerlabs"
  end

  def run
    connect
    until @server.eof? do
      msg = @server.gets.downcase
      pong if ping?
      respond if relevant?(msg)
    end
  end

  def connect
    irc_server = TCPSocket.open(@server, @port)
    irc_server.puts "USER #{@nick} 0 * #{@nick}"
    irc_server.puts "NICK #{@nick}"
    irc_server.puts "JOIN #{@channel}"
    #irc_server.puts "PRIVMSG #{@channel} :Message!" #intro greeting
  end

  def relevant?(msg)
    puts msg
    return false unless msg.include? "privmsg #{@channel} :"
    
    listening_for = ["test","testing"]
    listening_for.each do |keyword|
      return true if listening_for.include? keyword
    end
  end

  def respond
    response = "Hi! I work!"
    irc_server.puts "PRIVMSG #{@channel} :#{response}"
  end
end