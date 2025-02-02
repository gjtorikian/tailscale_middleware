# frozen_string_literal: true

DEBUG = ENV.fetch("DEBUG", false)
require "debug" if DEBUG

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "tailscale_middleware"

require "webmock/minitest"

require "rack/test"
require "rack/builder"
require "rack/lint"

require "minitest/autorun"
require "minitest/pride"
require "mocha/minitest"

require "webmocks"
