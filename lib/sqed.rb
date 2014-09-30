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

  attr_accessor :image, :quadrant_parser

  def initialize(image: image)
    @image = image
   end
 
  def quick_initialize
    crop_image
    quadrant_parse 
  end

  def crop_image
    @image = Sqed::AutoCropper.new(@image).img
  end

  def quadrant_parse
    @quadrant_parser = Sqed::QuadrantParser.new(image: @image)
  end

  # This is called
  # a = Sqed.new
  # a.result
  def result
    false
  end

  def text_from_quadrant(quadrant = 0, quadrant_specification: Sqed::QuadrantParser::QUADRANTS)
    raise 'provide an image' if @image.nil?
    i = @image #Sqed::WindowCropper.new(image: @image).result
  
    quadrant_parse if @quadrant_parser.nil?
    image =  @quadrant_parser.image_from_quadrant(quadrant)
    
    case quadrant_specification[quadrant]
    when :identifier
      return Sqed::BarcodeParser.new(image).barcodes
    when :specimen
      nil
    when :labels
      return Sqed::OcrParser.new(image).text
    when :standards
      return false 
    else
     raise
    end 

  end


end
