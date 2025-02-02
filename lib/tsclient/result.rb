# frozen_string_literal: true

require "values"

module Tsclient
  class Result < Value.new(:error, :result)
    def error?
      error
    end
  end
end
