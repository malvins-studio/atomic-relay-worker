module Adapters
  class Base
    def perform (payload)
      raise NotImplementedError
    end
  end
end
