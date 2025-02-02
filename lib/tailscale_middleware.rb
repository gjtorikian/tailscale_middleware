# frozen_string_literal: true

require_relative "tailscale_middleware/tailnet"
require_relative "tailscale_middleware/version"
require_relative "tsclient"

class TailscaleMiddleware
  def initialize(app, opts = {}, &block)
    @app = app
    @debug_mode = !!opts[:debug]
    @logger = @logger_proc = nil

    @tsclient = Tsclient.default_client
    logger = opts[:logger]
    if logger
      if logger.respond_to?(:call)
        @logger_proc = opts[:logger]
      else
        @logger = logger
      end
    end

    return unless block_given?

    if block.arity == 1
      yield(self)
    else
      instance_eval(&block)
    end
  end

  def debug?
    @debug_mode
  end

  def allow(&block)
    approved_tailnets << (tailnet = Tailnet.new)

    if block.arity == 1
      yield(tailnet)
    else
      tailnet.instance_eval(&block)
    end
  end

  def call(env)
    path = evaluate_path(env)

    debug(env) do
      [
        "Path-Info: #{path}",
      ].join("\n")
    end

    expected_tailnet = path_for_tailnet(path)

    # no matching path -> tailnet, keep request as is
    # because route isn't protected
    return @app.call(env) if expected_tailnet.nil?

    # tsclient is not running, can't verify integrity: fail
    return [404, {}, ["Not Found"]] unless tsclient_running?

    # we're connected to the right tailnet, keep request as is
    return @app.call(env) if current_tailnet(env) == expected_tailnet

    # we're connected to the wrong tailnet: fail
    [404, {}, ["Not Found"]]
  end

  protected

  def debug(env, message = nil, &block)
    (@logger || select_logger(env)).debug(message, &block) if debug?
  end

  def select_logger(env)
    @logger = if @logger_proc
      logger_proc = @logger_proc
      @logger_proc = nil
      logger_proc.call

    elsif defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger
      Rails.logger

    elsif env[RACK_LOGGER]
      env[RACK_LOGGER]

    else
      ::Logger.new($stdout).tap { |logger| logger.level = ::Logger::Severity::DEBUG }
    end
  end

  def evaluate_path(env)
    path = env["PATH_INFO"]

    if path
      path = Rack::Utils.unescape_path(path)

      path = Rack::Utils.clean_path_info(path) if Rack::Utils.valid_path?(path)
    end

    path
  end

  def path_for_tailnet(path)
    approved_tailnets.each do |tailnet|
      return tailnet.name if tailnet.route == "*" || path.start_with?(tailnet.route)
    end

    nil
  end

  def approved_tailnets
    @approved_tailnets ||= []
  end

  private def tsclient_running?
    status = @tsclient.status

    status.backend_state == "Running"
  end

  private def current_tailnet(env)
    ip_address = Rack::Request.new(env).ip

    requester = @tsclient.whois(ip_address)

    # current IP is not connected to a tailnet
    return if requester.node.name.nil?

    requester.node.name.split(".")[1]
  end
end
