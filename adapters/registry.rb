require_relative "sms_android"

module Adapters
  REGISTRY = {
    "sms_android" => SmsAndroid
  }

  def self.load(adapter_class_name)
    adapter_class = REGISTRY[adapter_class_name]
    raise "Unknown adapter: #{adapter_class_name}." unless adapter_class

    adapter_class.new
  end
end
