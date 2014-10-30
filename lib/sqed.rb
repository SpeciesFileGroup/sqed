# encoding: UTF-8

recent_ruby = RUBY_VERSION >= '2.1.1'
raise "IMPORTANT: sqed gem requires ruby >= 2.1.1" unless recent_ruby

require "RMagick"
include Magick
require_relative 'sqed_config'
require_relative "sqed/extractor"
require_relative "sqed/result"


# Instants take the following
# 1) A base image @image
# 2) A target extraction pattern
#
# Return a Sqed::Result
#    
#     a = Sqed.new(pattern: :right_t, image: image)
#     b = a.result # => Squed::Result instance
#
class Sqed
  
  attr_accessor :image, :pattern, :stage_image 

  def initialize(image: image, pattern: pattern)
    @image = image
    @pattern = pattern
    @pattern ||= :standard_cross 
  end

  def result
    return false if @image.nil? || @pattern.nil? 
    crop_image
    Sqed::Extractor.new(boundaries: boundaries, layout: SqedConfig::EXTRACTION_PATTERNS[@pattern][:layout], image: image).result
  end

  def boundaries
    SqedConfig::EXTACTION_PATTERNS[@pattern][:boundry_finder].new(image: @image).boundaries
  end

  def crop_image
    boundaries =  Sqed::BoundaryFinder::StageFinder.new(image: @image).boundaries
    # meh, have to think about extracting a single image (extractor gets it all) 
    @stage_image = false # Sqed::Extractor.new(boundaries: boundaries, image: @image).img
  end

end
