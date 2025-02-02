# frozen_string_literal: true

require "tailscale_middleware"

use Rack::Lint
use TailscaleMiddleware do
  allow do
    tailnet "crab-cake"
    route "/staff"
  end
end
