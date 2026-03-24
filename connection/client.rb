require "websocket-client-simple"
require "json"

require_relative "../config/env"
require_relative "../adapters/registry"

module Connection
  class Client
    def start
      ws = WebSocket::Client::Simple.connect(Config.SERVER_URL)

      payload = auth_payload.to_json
      ws.on :open do
        ws.send(payload)
        puts "Connected to server as: #{Config::DEVICE_ID}"
      rescue => e
        puts "Send error: #{e.class} - #{e.message}"
        puts e.backtrace
      end

      msg_handler = method(:handle_message)
      ws.on :message do |msg|
        msg_handler.call(ws, msg.data)
      end

      ws.on :close do
        puts "Disconnected. Reconnecting..."
        sleep 3
        exec("ruby worker.rb")
      end

      loop { sleep 1 }
    end

    def auth_payload
      {
        type: "auth",
        device_id: Config::DEVICE_ID,
        token: Config::AUTH_TOKEN
      }
    end

    def handle_message(ws, raw)
      data = JSON.parse(raw)

      return unless data["type"] == "job"

      puts "[WORKER] Received job #{data['id']}"

      adapter = Adapters.load(data["adapter"])
      result = adapter.perform(data["payload"])

      ws.send({
        type: "result",
        id: data["id"],
        status: result[:status],
        error: result[:error]
      }.to_json)
    end
  end
end
