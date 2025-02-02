# frozen_string_literal: true

require "values"

module Tsclient
  class Status < Value.new(:backend_state)
    def self.from(data)
      with(
        backend_state: data.dig("BackendState"),
      )
    end
  end
end
