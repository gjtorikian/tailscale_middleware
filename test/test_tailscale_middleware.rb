# frozen_string_literal: true

require "test_helper"

class TestTailscaleMiddleware < Minitest::Test
  def env(path: "/")
    Rack::MockRequest.env_for.merge("PATH_INFO" => path, "REMOTE_ADDR" => "10.123.121.65")
  end

  def load_app(name, options: {})
    Tsclient::ApiFinder.any_instance.stubs(:call).returns(URI.parse("http://localhost:61939/localapi"))

    Rack::Builder.new do
      eval(File.read(File.join(File.dirname(__FILE__), "fixtures", "#{name}.ru"))) # rubocop:disable Security/Eval
      map("/") do
        run(lambda do |_env|
          [200, { "content-type" => "text/html" }, ["success"]]
        end)
      end
    end
  end

  def test_request_comes_in_but_does_not_match_route
    stub_tailnet_request_status(status: 200)
    status, _headers, _response = load_app("subset").call(env)

    assert_equal(200, status)
  end

  def test_request_comes_in_but_tsclient_is_not_running
    stub_tailnet_request_status(status: 400)
    status, _headers, _response = load_app("all").call(env)

    assert_equal(404, status)
  end

  def test_request_comes_in_but_ip_is_not_found_by_whois
    stub_tailnet_request_status(status: 200)
    stub_tailnet_request_whois("rubber-duck", status: 400)

    status, _headers, _response = load_app("all").call(env)

    assert_equal(404, status)

    assert_requested_tailnet_status
    assert_requested_tailnet_whois
  end

  def test_request_comes_in_but_tailnet_names_do_not_match
    stub_tailnet_request_status(status: 200)
    stub_tailnet_request_whois("silly-billy", status: 200)

    status, _headers, _response = load_app("all").call(env)

    assert_equal(404, status)

    assert_requested_tailnet_status
    assert_requested_tailnet_whois
  end

  def test_grants_access_when_tailnets_match
    stub_tailnet_request_status(status: 200)
    stub_tailnet_request_whois("rubber-duck", status: 200)

    status, _headers, _response = load_app("all").call(env)

    assert_equal(200, status)

    assert_requested_tailnet_status
    assert_requested_tailnet_whois
  end

  def test_grants_access_to_some_subpaths_but_not_others
    stub_tailnet_request_status(status: 200)
    stub_tailnet_request_whois("black-cat", status: 200)

    status, _headers, _response = load_app("multi_subset").call(env(path: "/secrets"))

    assert_equal(200, status)

    status, _headers, _response = load_app("multi_subset").call(env(path: "/staff"))

    assert_equal(404, status)

    assert_requested_tailnet_status(times: 2)
    assert_requested_tailnet_whois(times: 2)
  end

  def test_grants_access_to_request_that_does_not_match_any_subpath
    status, _headers, _response = load_app("multi_subset").call(env(path: "/foo"))

    assert_equal(200, status)
  end
end
