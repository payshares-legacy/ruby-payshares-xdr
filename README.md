# Xdr

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'xdr'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install xdr

## Usage

TODO: Write usage instructions here

## Thread safety

Code generated by `xdrgen`, which targets this library, uses autoload extensively.
Since autoloading is not thread-safe, neither is code generated from xdrgen. To
work around this, any module including `XDR::Namespace` can be forced to load
all of it's children by calling `load_all!` on the module.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/xdr/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
