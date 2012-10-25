require 'em-websocket'

Thread.new do
  EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|
    ws.onopen    { ws.send "=== Websocket server started. ==="}
    ws.onmessage { |msg| ws.send "=== Server received message: #{msg} ===" }
    ws.onclose   { puts "=== WebSocket closed ===" }
  end
end
