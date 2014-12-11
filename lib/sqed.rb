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
  # initial image which is an instance of ImageMagick::image, containing background and stage, or just stage
  attr_accessor :image

  # the particular arrangement of the content, a symbol taken from SqedConfig::EXTRACTION_PATTERNS
  attr_accessor :pattern

  # the image that is the cropped content for parsing
  attr_accessor :stage_image, :stage_boundary, :boundaries, :auto_detect_border

  def initialize(image: image, pattern: pattern, auto_detect_border: true)
    @image = image

    @boundaries = nil
    @stage_boundary = Sqed::Boundaries.new(:internal_box) # a.k.a. stage

    @auto_detect_border = auto_detect_border

    @pattern = pattern
    @pattern ||= :standard_cross 

    set_stage_boundary if @auto_detect_border && @image
  end

  # This handles the case of
  #   s = Sqed.new()  # no image: @some_image on init
  #   s.image = @some_image
  #
  def image=(value)
    @image = value
    set_stage_boundary if @auto_detect_border 
  end

  def boundaries(force = false)
    @boundaries = get_stage_boundaries if @boundaries.nil? || force
    @boundaries
  end

  def native_boundaries
    # check for @boundaries.complete first? OR handle partial detections  ?!
    if @boundaries.complete
      @boundaries.offset(@stage_boundary)
    else
      nil
    end 
  end

  def stage_image
    crop_image if @stage_boundary.complete && @stage_image.nil?
    @stage_image 
  end

  def crop_image
    if @stage_boundary.complete
      @stage_image = @image.crop(*@stage_boundary.for(SqedConfig.index_for_section_type(:stage, :stage)))
    else
      @stage_image = @image 
    end
  end

  def result
    return false if @image.nil? || @pattern.nil? 
    crop_image
    extractor = Sqed::Extractor.new(
      boundaries: @boundaries,
      layout: SqedConfig::EXTRACTION_PATTERNS[@pattern][:layout],
      image: @stage_image)
    extractor.result
  end

  protected

  def set_stage_boundary
    @stage_boundary = Sqed::BoundaryFinder::StageFinder.new(image: @image).boundaries
    if !@stage_boundary.complete
      @stage_boundary.coordinates[0] = [0, 0, @image.columns, @image.rows] 
    end
  end

  def get_stage_boundaries
    SqedConfig::EXTRACTION_PATTERNS[@pattern][:boundary_finder].new(
      image: stage_image, 
      layout: SqedConfig::EXTRACTION_PATTERNS[@pattern][:layout]
    ).boundaries
  end

end
