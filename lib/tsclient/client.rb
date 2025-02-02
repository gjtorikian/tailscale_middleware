# frozen_string_literal: true

require "net/http"
require "socket"
require "json"

module Tsclient
  class Client
    attr_reader :api_uri

    def initialize(uri:)
      @api_uri = uri.freeze
      freeze
    end

    def tailscale_ips
      api_get(:status).result.dig("TailscaleIPs")
    end

    def whois(addr)
      unless addr.include?(":")
        addr += ":80"
      end
      response = api_get(:whois, addr: addr)
      if response.error?
        nil
      else
        Profile.from(response.result)
      end
    end

    def status
      response = api_get(:status)

      if response.error?
        nil
      else
        Status.from(response.result)
      end
    end

    private

    def api_get(endpoint, params = {})
      case @api_uri.scheme
      when "http", "https"
        # All we actually need is the port & password, but expect well formed URI to be passed in
        Net::HTTP.start(@api_uri.host, @api_uri.port, use_ssl: (@api_uri.scheme == "https")) do |http|
          req = Net::HTTP::Get.new(format_endpoint(endpoint, params))
          req.basic_auth("", @api_uri.password)
          req.content_type = "application/json"
          res = http.request(req)
          case res
          when Net::HTTPOK
            Result.with(error: false, result: JSON.parse(res.body))
          when Net::HTTPNotFound
            Result.with(error: true, result: res)
          end
        end
      when "unix"
        UNIXSocket.open(@api_uri.path) do |socket|
          request = "GET #{format_endpoint(endpoint, params)} HTTP/1.1\r\n"
          request += "Host: local-tailscaled.sock\r\n"
          request += "Content-Type: application/json\r\n"
          request += "Connection: close\r\n"
          request += "\r\n"

          socket.write(request)
          res = socket.read

          _headers, response = res.split("\r\n\r\n")
          _length, body, status = response.split("\r\n")

          if status.to_i.zero?
            Result.with(error: false, result: JSON.parse(body))
          else
            Result.with(error: true, result: body)
          end
        end
      else
        raise "Can't handle api uri with scheme #{@api_uri.scheme.inspect}"
      end
    end

    def format_endpoint(endpoint, params)
      "/localapi/v0/#{endpoint}?#{params.map { |k, v| "#{k}=#{v}" }.join("&")}"
    end
  end
end
