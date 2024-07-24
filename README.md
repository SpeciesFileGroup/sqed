
[![Continuous Integration Status][1]][2]

# Sqed

Sqed is a gem that faciliates metadata extraction from images of staged collection objects. 

## Installation

Add this line to your application's Gemfile:

    gem 'sqed'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sqed

## Usage

For the time being, see specs.

## Experiment with irb

```Ruby
require 'sqed'


i = Magick::Image.read(File.expand_path('~/Downloads/') + '/img_0129.jpg').first
s = Sqed.new( image: i, pattern: :lep_stage, boundary_color: :red, has_border: false )
r = s.result
r.write_images # => ./temp/*.jpg

# Without thumbnail
s = Sqed.new( image: i, pattern: :lep_stage, boundary_color: :red, has_border: false, use_thumbnail: false )

```

## Contributing

1. Fork it ( http://github.com/SpeciesFileGroup/sqed/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[1]: https://secure.travis-ci.org/SpeciesFileGroup/sqed.png?branch=master
[2]: http://travis-ci.org/SpeciesFileGroup/sqed?branch=master

