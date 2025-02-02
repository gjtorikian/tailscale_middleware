# frozen_string_literal: true

require "values"

module Tsclient
  class Node < Value.new(:name, :computed_name, :hostname)
    def self.from(data)
      with(
        name: data.dig("Node", "Name"),
        computed_name: data.dig("Node", "ComputedName"),
        hostname: data.dig("Node", "Hostinfo", "Hostname"),
      )
    end
  end
end
