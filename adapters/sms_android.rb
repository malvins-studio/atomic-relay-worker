require_relative "base"

module Adapters
  class SmsAndroid < Base
    def perform(payload)
      to = payload["to"]
      body = payload["body"]

      success = system("termux-sms-send -n '#{to}' '#{body}'")

      if success
        { status: "sent" }
      else
        { status: "failed", error: "Could not determine the issue. Check worker logs if defnied." }
      end
    rescue => e
      { status: "failed", error: e.message }
    end
  end
end
