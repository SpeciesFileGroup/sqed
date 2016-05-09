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

  # Boolean, whether to do the boundary detection (not stage detection at present) against a thumbnail version of the passed image (faster, less accurate, true be default) 
  attr_accessor :use_thumbnail

  # Provide a specific layout, overrides metadata taken from pattern
  attr_accessor :layout

  # Provide a metadata map, overrides metadata taken from pattern
  attr_accessor :metadata_map

  # Provide a boundary_finder, overrides metadata taken from pattern
  attr_accessor :boundary_finder 
   
  def initialize(target_image: image, target_pattern: pattern, has_border: true, boundary_color: :green, use_thumbnail: true, boundary_finder: nil, target_layout: nil, metadata_map: nil)
    raise 'extraction pattern not defined' if target_pattern && !SqedConfig::EXTRACTION_PATTERNS.keys.include?(target_pattern) 

    # data, and stubs for results
    @image = target_image
    @boundaries = nil
    @stage_boundary = Sqed::Boundaries.new(:internal_box) 

    # extraction metadata
    @pattern = (target_pattern || :cross)
    @has_border = has_border
    @boundary_finder = boundary_finder.constantize if boundary_finder
    @layout = layout
    @metadata_map = metadata_map
    @boundary_color = boundary_color
    @use_thumbnail = use_thumbnail

    set_stage_boundary if @image
  end

  # @return [Hash]
  #   federate extraction options and apply user provided over-rides
  def extraction_metadata
    data = SqedConfig::EXTRACTION_PATTERNS[pattern]
    
    data.merge!(boundary_color: boundary_color) 
    data.merge!(boundary_finder: @boundary_finder) if boundary_finder
    data.merge!(has_border: has_border) 
    data.merge!(target_layout: layout) if layout 
    data.merge!(target_metadata_map: metadata_map) if metadata_map
    data.merge!(use_thumbnail: use_thumbnail) 
    data
  end

  # @return [ImageMagick::Image]
  #   set the image if it's not set during initialize(), not commonly used
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
    if has_border 
      @stage_image = image.crop(*stage_boundary.for(SqedConfig.index_for_section_type(:stage, :stage)), true)
    else
      @stage_image = image 
    end
    @stage_image
  end

  def result
    # pattern.nil? is no longer true -> must have values for all extraction_metadata keys
    return false if image.nil? || pattern.nil? 
    extractor = Sqed::Extractor.new(
      target_boundaries: boundaries,
      target_metadata_map: extraction_metadata[:metadata_map],
      target_image: stage_image)
    extractor.result
  end

  # @return [Hash]
  #   an overview of data/metadata, for debugging purposes only
  def attributes
    { target_image: image,
      boundaries: boundaries,
      stage_boundary: stage_boundary
    }.merge!(extraction_metadata)
  end

  protected

  def set_stage_boundary
    if has_border
      boundary = Sqed::BoundaryFinder::StageFinder.new(target_image: image).boundaries
      if boundary.populated? 
        @stage_boundary.set(0, boundary.for(0)) 
      else
        raise 'error detecting stage'
      end
    else
      @stage_boundary.set(0, [0, 0, image.columns, image.rows])
    end
  end

  def get_section_boundaries
    options = {target_image: stage_image, use_thumbnail: use_thumbnail}
    options.merge!( target_layout: extraction_metadata[:layout] ) unless extraction_metadata[:boundary_finder].name == 'Sqed::BoundaryFinder::CrossFinder'
    options.merge!( boundary_color: boundary_color) if extraction_metadata[:boundary_finder].name == 'Sqed::BoundaryFinder::ColorLineFinder'

    extraction_metadata[:boundary_finder].new(options).boundaries
  end

end
