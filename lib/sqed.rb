# encoding: UTF-8

recent_ruby = RUBY_VERSION >= '2.1.1'
raise "IMPORTANT: sqed gem requires ruby >= 2.1.1" unless recent_ruby

require "RMagick"
# require_relative "sqed/version" # check to see this is right/wrong vs. rubyBHL
require_relative "sqed/quadrant_parser"
require_relative "sqed/ocr_parser"
require_relative "sqed/barcode_parser"
require_relative "sqed/window_cropper"

class Sqed

  DEFAULT_TMP_DIR = "/tmp"

  attr_accessor :image

  def initialize(image: image)
    @image = image
  end

  # This is called
  # a = Sqed.newpwd
  # a.result
  def result
    false
  end

  # This is called like Sqed.foo
  def self.foo

  end

end
