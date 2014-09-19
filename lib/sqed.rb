# encoding: UTF-8

recent_ruby = RUBY_VERSION >= '2.1.1'
raise "IMPORTANT: sqed gem requires ruby >= 2.1.1" unless recent_ruby

require "RMagick"

# require_relative "sqed/version" # check to see this is right/wrong vs. rubyBHL
require_relative "sqed/quadrant_parser"
require_relative "sqed/ocr_parser"
require_relative "sqed/barcode_parser"
require_relative "sqed/window_cropper"
require_relative "sqed/auto_cropper"

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

  def text_from_quadrant(quadrant = 4)
    raise 'provide an image' if @image.nil?
    i = Sqed::WindowCropper.new(image: @image).result
    if quadrant == 3
        j = Sqed::QuadrantParser.new(image: i).image_from_quadrant(quadrant)
        k = Sqed::OcrParser.new(j).text
      return k
    end
    if quadrant == 2
      l = Sqed::WindowCropper.new(image: @image).result
      if l.nil?
        l = Sqed::BarcodeParser.new(image: ImageHelpers.barcode_image)
      end
      k = Sqed::QuadrantParser.new(image: l).image_from_quadrant(quadrant)
      m = Sqed::BarcodeParser.new(k)
      n = m.barcodes
      return m
    end
  end
end
