# gibberish_detector

The gibberish_detector gem takes a string and analyzes it for gibberish characters.  If it detects gibberish, it returns true and if not it returns false.  Based on [buggedcom's Gibberish-Detector-PHP](https://github.com/buggedcom/Gibberish-Detector-PHP) and, in turn, [rrenaud's Gibberish-Detector](https://github.com/rrenaud/Gibberish-Detector).

```ruby
"aosdfj".gibberish?
#=> true

"hello world".gibberish?
#=> false
```

## Installation

Add this line to your application's Gemfile:

    gem 'gibberish_detector'

And then execute:

    $ bundle

Or install it yourself with:

    $ gem install gibberish_detector

## Usage

You may use the `.gibberish?` predicate method on a string, or call the detector directly with `GibberishDetector.gibberish?`.

```ruby
"aosdfj".gibberish?
#=> true

"Hello world".gibberish?
#=> false

## Functionally equivalent to:

GibberishDetector.gibberish?("aosdfj")
#=> true

GibberishDetector.gibberish?("Hello world")
#=> false

```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Credits

Please see [CREDITS.md](https://github.com/mchitten/gibberish_detector/blob/master/CREDITS.md) for the well deserved credits for this functionality.
