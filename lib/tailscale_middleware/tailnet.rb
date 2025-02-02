# frozen_string_literal: true

class TailscaleMiddleware
  class Tailnet
    attr_reader :name

    def initialize
      @name = nil
      @route = nil
    end

    def tailnet(tailnet_name)
      @name = tailnet_name
    end

    def route(path = nil)
      return @route if path.nil?

      @route = path
    end
  end
end
