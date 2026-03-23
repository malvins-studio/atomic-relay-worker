require "websocket-client-simple"
require "json"

require_relative "../config/env"
require_relative "../adapters/registry"

module Connection
  class Client
    def start
      ws = WebSocket::Client::Simple.connect(Config.SERVER_URL)

      ws.on :open do
        ws.send(auth_payload.to_json)
        puts "Connected as #{Config::DEVICE_ID}"
      end

      ws.on :message do |msg|
        handle_message(ws, msg.data)
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
        devide_id: Config::DEVICE_ID,
        token: Config::TOKEN
      }
    end

    def handle_message(ws, raw)
      data = JSON.parse(raw)

      return unless data["type"] == "job"

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
