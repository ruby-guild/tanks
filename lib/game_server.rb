require 'em-websocket'

class GameServer
  attr_accessor :host, :port

  def initialize(host, port)
    @host = host
    @port = port
  end

  def start
    Thread.new(host, port) do |hst, prt|

      EventMachine.run {
        @channel = EM::Channel.new

        EventMachine::WebSocket.start(:host => hst, :port => prt, :debug => true) do |ws|

          ws.onopen {
            sid = @channel.subscribe { |msg| ws.send msg }
            @channel.push "#{sid} connected!"

            ws.onmessage { |msg|
              @channel.push "<#{sid}>: #{msg}"
            }

            ws.onclose {
              @channel.unsubscribe(sid)
            }
          }

        end

        puts "Server started"
      }

    end
  end

end
