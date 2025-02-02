# frozen_string_literal: true

def stub_tailnet_request_status(status: 200)
  body = if status == 200
    { "BackendState" => "Running" }
  elsif status == 400
    { "BackendState" => "NotRunning" }
  end

  stub_request(:get, "http://localhost:61939/localapi/v0/status")
    .to_return(
      status: 200,
      headers: { content_type: "application/json; charset=utf-8" },
      body: body.to_json,
    )
end

def assert_requested_tailnet_status(times: 1)
  assert_requested(:get, "http://localhost:61939/localapi/v0/status", times: times)
end

def stub_tailnet_request_whois(network, status: 200)
  body = if status == 200
    {
      "UserProfile" => {
        "LoginName" => "someone@somewhere.com",
        "DisplayName" => "Billy T",
        "ProfilePicURL" => "https://lh3.googleusercontent.com/a/asd-Mvxv",
      },
      "Node" => {
        "Name" => "nezu.#{network}.ts.net.",
        "ComputedName" => "nezu",
        "Hostname" => "Nezu",
      },
    }
  else
    {}
  end

  stub_request(:get, "http://localhost:61939/localapi/v0/whois?addr=10.123.121.65:80")
    .to_return(
      status: 200,
      headers: { content_type: "application/json; charset=utf-8" },
      body: body.to_json,
    )
end

def assert_requested_tailnet_whois(times: 1)
  assert_requested(:get, "http://localhost:61939/localapi/v0/whois?addr=10.123.121.65:80", times: times)
end
