# frozen_string_literal: true

require_relative "tsclient/api_finder"
require_relative "tsclient/client"
require_relative "tsclient/error"
require_relative "tsclient/node"
require_relative "tsclient/profile"
require_relative "tsclient/result"
require_relative "tsclient/status"

module Tsclient
  def self.default_client(api_finder: ApiFinder.new)
    return @default_client if defined?(@default_client)

    if (uri = api_finder.call)
      @default_client = Client.new(uri: uri)
    else
      raise Error, "Could not find localapi on this machine"
    end
  end
end
