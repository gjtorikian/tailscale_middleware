# TailscaleMiddleware

`TailscaleMiddleware` provides support for protecting routes behind a [tailnet](https://tailscale.com/kb/1136/tailnet).

## Installation

Install the gem:

`gem install tailscale_middleware`

Or in your Gemfile:

```ruby
gem 'tailscale_middleware'
```

## Configuration

### Rails Configuration

For Rails, you'll need to add this middleware on application startup. A practical way to do this is with an initializer file, like this:

```ruby
# config/initializers/tailscale_middleware.rb

Rails.application.config.middleware.insert_before 0, TailscaleMiddleware do
  ...
end
```

Use `insert_before` to make sure `TailscaleMiddleware` runs at the beginning of the stack; this ensures it isn't interfered with by other middleware.

See The [Rails Guide to Rack](http://guides.rubyonrails.org/rails_on_rack.html) for more details on Rack middleware. Read more about configuring middleware [in the Rails Guides](https://guides.rubyonrails.org/configuring.html#configuring-middleware)

### Rack Configuration

NOTE: If you're running Rails, adding a `config/initializers/tailscale_middleware.rb` should be enough.

For pure Rack, in `config.ru`, configure `TailscaleMiddleware` by passing a block to the `use` command:

```ruby
use TailscaleMiddleware do
  ...
end
```

### Configuring for every path

```ruby
TailscaleMiddleware do
  allow do
    tailnet "rubber-duck"
    path "*"
  end
end
```

In this example:

1. If your server is not connected to a tailnet, the request is denied
2. If your client is not connected to the `rubber-duck` tailnet, the request is denied
3. If your client is connected to the `rubber-duck` tailnet, the request is passed along

### Configuring for some paths

```ruby
TailscaleMiddleware do
  allow do
    tailnet "crab-cake"
    path "/staff"
  end
end
```

In this example:

1. If your client is does not request anything under `/staff`, the request is passed along
2. If your client requests something under `/staff`, but is not connected to the `crab-cake` tailnet, the request is denied
3. If your client requests something under `/staff`, and is connected to the `crab-cake` tailnet, the request is passed along

### Configuring for some paths

```ruby
TailscaleMiddleware do
  allow do
    tailnet "black-cat"
    route "/secrets"
  end

  allow do
    tailnet "crab-cake"
    route "/staff"
  end
end
```

In this example:

1. If your client is does not request anything under `/secrets` or `/staff`, the request is passed along
2. If your client requests something under `/secrets`, but is not connected to the `black-cat` tailnet, the request is denied
3. If your client requests something under `/secrets`, and is connected to the `black-cat` tailnet, the request is passed along
4. If your client requests something under `/staff`, but is not connected to the `crab-cake` tailnet, the request is denied
5. If your client requests something under `/staff`, and is connected to the `crab-cake` tailnet, the request is passed along

### Configuration Reference

#### Middleware Options

| Option   | Type    | Default | Description                                                                                                                                                                                                                        |
| -------- | ------- | ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `debug`  | Boolean | `false` | Enables debug logging.                                                                                                                                                                                                             |
| `logger` | Object  | `nil`   | Specify the logger to log to. If a proc is provided, it will be called when a logger is needed. This is helpful in cases where the logger is initialized after `TailscaleMiddleware` is initially configured, like `Rails.logger`. |

Pass these options along with the middleware, like:

```
Rails.application.config.middleware.insert_before 0, TailscaleMiddleware, debug: false, logger: (-> { Rails.logger }) do
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gjtorikian/tailscale_middleware. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/gjtorikian/tailscale_middleware/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TailscaleMiddleware project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/gjtorikian/tailscale_middleware/blob/main/CODE_OF_CONDUCT.md).
