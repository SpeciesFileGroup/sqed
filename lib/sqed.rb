# encoding: UTF-8

recent_ruby = RUBY_VERSION >= '2.1.1'
raise "IMPORTANT: sqed gem requires ruby >= 2.1.1" unless recent_ruby

require "RMagick"
include Magick

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

  require_relative 'sqed_config'
  require_relative "sqed/extractor"
  require_relative "sqed/result"

  # initial image which is an instance of ImageMagick::Image, containing background and stage, or just stage
  attr_accessor :image

  # the particular arrangement of the content, a symbol taken from SqedConfig::EXTRACTION_PATTERNS
  attr_accessor :pattern

  # the image that is the cropped content for parsing
  attr_accessor :stage_image

  # a Sqed::Boundaries instance that stores the coordinates of the stage 
  attr_accessor :stage_boundary
 
  # a Sqed::Boundaries instances that contains the coordinates of the interan stage sections
  attr_accessor :boundaries
 
  # Boolean, whether to detect the border on initialization, i.e. new()
  attr_accessor :auto_detect_border 
 
  # a symbol, :red, :green, :blue, describing the boundary color within the stage 
  attr_accessor :boundary_color

  def initialize(image: image, pattern: pattern, auto_detect_border: true, boundary_color: :green)
    @image = image
    @boundaries = nil
    @stage_boundary = Sqed::Boundaries.new(:internal_box) 
    @auto_detect_border = auto_detect_border
    @pattern = pattern
    @pattern ||= :standard_cross
    @boundary_color = boundary_color

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
    @boundaries = get_section_boundaries if @boundaries.nil? || force
    @boundaries
  end

  # Return [Sqed::Boundaries instance]
  #   a boundaries instance that has the original image (prior to cropping stage) coordinates
  def native_boundaries
    # check for @boundaries.complete first? OR handle partial detections  ?!
    if @boundaries.complete
      @boundaries.offset(@stage_boundary)
    else
      nil
    end 
  end

  # return [Image]
  #   crops the image if not already done
  def stage_image
    crop_image if @stage_boundary.complete && @stage_image.nil?
    @stage_image 
  end

  # return [Image]
  #   crops the stage if not done, then sets/returns @stage_image
  def crop_image
    if @stage_boundary.complete
      @stage_image = @image.crop(*@stage_boundary.for(SqedConfig.index_for_section_type(:stage, :stage)), true)
    else
      @stage_image = @image 
    end
  end

  def result
    return false if @image.nil? || @pattern.nil? 
    extractor = Sqed::Extractor.new(
      boundaries: boundaries,
      metadata_map: SqedConfig::EXTRACTION_PATTERNS[@pattern][:metadata_map],
      image: stage_image)
    extractor.result
  end

  def attributes
    {
      image: @image,
      boundaries: @boundaries,
      stage_boundary: @stage_boundary,
      auto_detect_border: @auto_detect_border,
      pattern: @pattern,
      boundary_color: @boundary_color
    }
  end

  protected

  def set_stage_boundary
    @stage_boundary = Sqed::BoundaryFinder::StageFinder.new(image: @image).boundaries
    if !@stage_boundary.complete
      @stage_boundary.coordinates[0] = [0, 0, @image.columns, @image.rows] 
    end
  end

  def get_section_boundaries
    boundary_finder_class = SqedConfig::EXTRACTION_PATTERNS[@pattern][:boundary_finder]

    options = {image: stage_image}
    options.merge!( layout: SqedConfig::EXTRACTION_PATTERNS[@pattern][:layout] ) unless  boundary_finder_class.name == 'Sqed::BoundaryFinder::CrossFinder'
    options.merge!( boundary_color: @boundary_color) if  boundary_finder_class.name == 'Sqed::BoundaryFinder::ColorLineFinder'

    boundary_finder_class.new(options).boundaries
  end

end
