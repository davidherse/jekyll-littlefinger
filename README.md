# Jekyll::Littlefinger

A little fingerprinting gem for Jekyll assets.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jekyll-littlefinger'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jekyll-littlefinger

## Usage

### Config

You can adjust the config by adding the following to your `_config.rb` file. Here is the the default settings.

    littlefinger:
      add_baseurl: true
      in_production: true
      in_development: true
      include:
        - assets

All files found in the `include:` list will be fingerprinted. You can list folders and files.

In your template use the `fingerprint` filter to render the correct path (including the `baseurl` unless you disable it in the config.)

    {{ 'assets/img/foo.png' | fingerprint }}

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/davidherse/jekyll-littlefinger. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Jekyll::Littlefinger project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/davidherse/jekyll-littlefinger/blob/master/CODE_OF_CONDUCT.md).
