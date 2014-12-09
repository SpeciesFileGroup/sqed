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
#     b = a.result # => Sqed::Result instance
#
class Sqed
  # initial image which is an instance of ImageMagick::image, containing background and stage
  attr_accessor :image

  # the particular arrangement of the content, a symbol taken from SqedConfig::EXTRACTION_PATTERNS
  attr_accessor :pattern

  # the image that is the cropped content for parsing
  attr_accessor :stage_image, :stage_boundary

  def initialize(image: image, pattern: pattern)
    @image = image
    @stage_boundary = Sqed::Boundaries.new(:internal_box) # a.k.a. stage
    @stage_boundary.coordinates[0] = [0, 0, @image.columns, @image.rows] if @image
    @pattern = pattern
    @pattern ||= :standard_cross 
  end

  def result
    return false if @image.nil? || @pattern.nil? 
    crop_image
    extractor = Sqed::Extractor.new(
      boundaries: boundaries,
      layout: SqedConfig::EXTRACTION_PATTERNS[@pattern][:layout],
      image: @stage_image)
    extractor.result
  end

  def boundaries
    SqedConfig::EXTRACTION_PATTERNS[@pattern][:boundary_finder].new(
      image: @image, 
      layout: SqedConfig::EXTRACTION_PATTERNS[@pattern][:layout],
    ).boundaries
  end

  def native_boundaries
    boundaries.offset(@stage_boundary)
  end
  def crop_image
    @stage_boundary = Sqed::BoundaryFinder::StageFinder.new(image: @image).boundaries
    @stage_image = @image.crop(*@stage_boundary.for(SqedConfig.index_for_section_type(:stage, :stage)))
  end

end
