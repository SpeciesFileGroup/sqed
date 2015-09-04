# encoding: UTF-8

recent_ruby = RUBY_VERSION >= '2.1.1'
raise "IMPORTANT: sqed gem requires ruby >= 2.1.1" unless recent_ruby

require "rmagick"

# Instants take the following
# 1) A base image @image
# 2) A target extraction pattern
#
# Return a Sqed::Result
#    
#     a = Sqed.new(pattern: :vertical_offset_cross, image: image)
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
  attr_accessor :has_border 
 
  # a symbol, :red, :green, :blue, describing the boundary color within the stage 
  attr_accessor :boundary_color

  # Boolean, whether to do the boundary detection against a thumbnail version fo the past image (faster, less accurate, true be default) 
  attr_accessor :use_thumbnail

  def initialize(image: image, pattern: pattern, has_border: true, boundary_color: :green, use_thumbnail: true)
    raise 'extraction pattern not defined' if pattern && !SqedConfig::EXTRACTION_PATTERNS.keys.include?(pattern) 
 
    @image = image
    @boundaries = nil
    @stage_boundary = Sqed::Boundaries.new(:internal_box) 
    @has_border = has_border
    @pattern = pattern
    @pattern ||= :cross
    @boundary_color = boundary_color

    set_stage_boundary if @image
  end

  # Attributes accessor overides
  def image=(value)
    @image = value
    set_stage_boundary 
    @image
  end

  def boundaries(force = false)
    @boundaries = get_section_boundaries if @boundaries.nil? || force
    @boundaries
  end

  def stage_boundary
    set_stage_boundary if !@stage_boundary.populated?
    @stage_boundary
  end

  def stage_image
   crop_image if @stage_image.nil?
   @stage_image 
  end

  # Return [Sqed::Boundaries instance]
  #   a boundaries instance that has the original image (prior to cropping stage) coordinates
  def native_boundaries
    # check for @boundaries.complete first? OR handle partial detections  ?!
    if @boundaries.complete
      @boundaries.offset(stage_boundary)
    else
      nil
    end 
  end

  # return [Image]
  #   crops the stage if not done, then sets/returns @stage_image
  def crop_image
    if @has_border 
      @stage_image = @image.crop(*stage_boundary.for(SqedConfig.index_for_section_type(:stage, :stage)), true)
    else
      @stage_image = @image 
    end
    @stage_image
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
      stage_boundary: stage_boundary,
      has_border: @has_border,
      pattern: @pattern,
      boundary_color: @boundary_color, 
      use_thumbnail: @use_thumbnail
    }
  end

  protected

  def set_stage_boundary
    if @has_border
      boundary = Sqed::BoundaryFinder::StageFinder.new(image: @image).boundaries
      if boundary.populated? 
        @stage_boundary.set(0, boundary.for(0)) #  = boundary
      else
        raise 'error detecting stage'
      end
    else
      @stage_boundary.set(0, [0, 0, @image.columns, @image.rows])
    end
  end

  # TODO make this a setter
  def get_section_boundaries
    boundary_finder_class = SqedConfig::EXTRACTION_PATTERNS[@pattern][:boundary_finder]

    options = {image: stage_image, use_thumbnail: use_thumbnail}
    options.merge!( layout: SqedConfig::EXTRACTION_PATTERNS[@pattern][:layout] ) unless  boundary_finder_class.name == 'Sqed::BoundaryFinder::CrossFinder'
    options.merge!( boundary_color: @boundary_color) if boundary_finder_class.name == 'Sqed::BoundaryFinder::ColorLineFinder'

    boundary_finder_class.new(options).boundaries
  end

end
