# encoding: UTF-8

recent_ruby = RUBY_VERSION >= '2.4.1'
raise Sqed::Error, 'IMPORTANT: sqed gem requires ruby >= 2.4.1' unless recent_ruby

require 'rmagick'
require 'sqed_utils'

# Instances take the following
# 1) An :image @image
# 2) A target extraction pattern, or individually specified attributes
#
# Return a Sqed::Result
#
#     a = Sqed.new(pattern: :vertical_offset_cross, image: image)
#     b = a.result # => Sqed::Result instance
#
class Sqed

  require_relative 'sqed/error'
  require_relative 'sqed_config'
  require_relative 'sqed/extractor'
  require_relative 'sqed/result'


  # @return [Sqed::Boundaries instance, nil]
  #   Contains the coordinates of the internal stage sections. Calculates when set.
  attr_accessor :boundaries

  # @return [Symbol] like `:red`, `:green`, `:blue`, defaults to `:green`
  # describing the boundary color within the stage
  attr_accessor :boundary_color

  # @return [Sqed::BoundaryFinder::<Klass>]
  # Provide a boundary_finder, overrides metadata taken from pattern
  attr_accessor :boundary_finder

  # @return [Boolean] defaults to `true`
  #   when true detects border on initialization
  attr_accessor :has_border

  # initial image which is an instance of Magick::Image, containing background and stage, or just stage
  attr_accessor :image

  # @return [Symbol] like `:cross`
  # !! Provide a specific layout, passed as option :layout, overrides layout metadata taken from :pattern, defaults to `:cross`
  attr_accessor :layout

  # Provide a metadata map, overrides metadata taken from pattern.
  # No calculations are done here.
  attr_accessor :metadata_map

  # !optional! A lookup macro that if provided sets boundary_finder, layout, and metadata_map.
  # These can be individually overwritten.
  # Legal values are symbols taken from SqedConfig::EXTRACTION_PATTERNS.
  #
  # !! Patterns are not intended to be persisted in external databases (they may change names). !!
  # To persist Sqed metadata in something like Postgres reference individual
  # attributes (e.g. layout, metadata_map, boundary_finder).
  #
  # @return [Symbol] like `:seven_slot`, see Sqed::CONFIG for valid options,
  # default value is `nil`
  #   not required if layout, metadata_map, and boundary_finder are provided
  attr_accessor :pattern

  # The image that is the cropped content for parsing
  # !! Does not require `metadata_map` or `layout`
  attr_accessor :stage_image

  # @return [Sqed::Boundaries instance]
  #   stores the coordinates of the stage
  # !! Does not require `metadata_map` or `layout`
  attr_accessor :stage_boundary

  # @return [Boolean] defaults to `true` (faster, less accurate)
  #  if `true` do the boundary detection (not stage detection at present)
  # against a thumbnail version of the passed image
  attr_accessor :use_thumbnail

  def initialize(**opts)
    # extraction metadata
    @image = opts[:image]

    configure(opts)
    stub_results
  end

  # @return [Hash]
  #   federate extraction options
  def extraction_metadata
    {
      boundary_finder: boundary_finder,
      layout: layout,
      metadata_map: metadata_map,
      boundary_color: boundary_color,
      has_border: has_border,
      use_thumbnail: use_thumbnail
    }
  end

  # @return [Magick::Image]
  #   set the image if it's not set during initialize(), not commonly used
  def image=(value)
    @image = value if value.kind_of?(::Magick::Image)
  end

  def stage_boundary
    compute_stage_boundary if !@stage_boundary.populated?
    @stage_boundary
  end

  def stage_image
    @stage_image ||= crop_image
  end

  # @return [Image]
  #   crops the stage if not done, then sets/returns @stage_image
  def crop_image

    begin

      if has_border && image
        @stage_image = image.crop(*stage_boundary.for(SqedConfig.index_for_section_type(:stage, :stage)), true)
      elsif image
        @stage_image = image
      end
      @stage_image

    rescue Sqed::Error
      raise
    rescue
      raise Sqed::Error, 'error cropping image'
    end

  end

  def boundaries(force = false)
    begin

      if force
        @boundaries = get_section_boundaries
      else
        @boundaries ||= get_section_boundaries
      end

      @boundaries

    rescue Sqed::Error
      raise
    rescue # XXXX
      raise Sqed::Error, 'error processing boundaries'
    end
  end

  # @return [Boolean]
  #   `true` if all boundary detection and image processing
  #   has been calculated with error
  #
  def extractable?
    stage_image && metadata_map && boundaries
  end

  # @return [Sqed::Result, false]
  def result
    return false unless extractable?

    extractor = Sqed::Extractor.new(
      boundaries: boundaries,
      metadata_map: metadata_map,
      image: stage_image
    )

    extractor.result
  end

  private

  # @return [Sqed::Boundaries instance, nil]
  #   a boundaries instance that has the original image (prior to cropping stage) coordinates
  def native_boundaries
    if @boundaries.complete
      @boundaries.offset(stage_boundary)
    else
      nil
    end
  end

  # @return [Hash]
  #   an overview of data/metadata, for debugging purposes only
  def attributes
    { image: image,
      boundaries: boundaries,
      stage_boundary: stage_boundary
    }.merge!(extraction_metadata)
  end

  def configure(opts)
    configure_from_pattern(opts[:pattern])
    configure_boundary_finder(opts)
    configure_layout(opts)
    configure_metadata_map(opts)

    raise Sqed::Error, 'boundary_finder not provided' if @boundary_finder.nil?

    @has_border = opts[:has_border]
    @has_border = true if @has_border.nil?

    @boundary_color = opts[:boundary_color]
    @boundary_color ||= :green

    @use_thumbnail = opts[:use_thumbnail]
    @use_thumbnail = true if @use_thumbnail.nil?
  end

  def configure_from_pattern(value)
    return if value.nil?
    value = value.to_sym
    raise Sqed::Error, "provided extraction pattern '#{value}' not defined" if !SqedConfig::EXTRACTION_PATTERNS.keys.include?(value)
    @pattern = value
    a = SqedConfig::EXTRACTION_PATTERNS[pattern]
    @boundary_finder = a[:boundary_finder]
    @layout = a[:layout]
    @metadata_map = a[:metadata_map]

    true
  end

  def configure_boundary_finder(opts)
    @boundary_finder = opts[:boundary_finder] if !opts[:boundary_finder].nil?
  end

  def configure_layout(opts)
    @layout = opts[:layout]
    if p = opts[:pattern]
      @layout ||= SqedConfig::EXTRACTION_PATTERNS[p][:layout]
    end
    @layout ||= :cross
  end

  def configure_metadata_map(opts)
    @metadata_map = opts[:metadata_map] unless opts[:metadata_map].nil?
  end

  # stubs for data and results
  def stub_results
    @boundaries = nil
    @stage_boundary = Sqed::Boundaries.new(:internal_box)
    compute_stage_boundary if @image
  end

  # @return [Boundaries, nil]
  def get_section_boundaries

    boundary_finder.new(**section_params).boundaries

  end

  # @return [Hash]
  #   variables for the isolated stage image
  def section_params
    {
      image: stage_image,
      use_thumbnail: use_thumbnail,
      layout: layout,
      boundary_color: boundary_color
    }
  end

  def compute_stage_boundary
    if has_border
      boundary = Sqed::BoundaryFinder::StageFinder.new(image: image).boundaries
      if boundary&.populated?
        @stage_boundary.set(0, boundary.for(0))
      else
        raise Sqed::Error, 'error detecting stage'
      end
    else
      @stage_boundary.set(0, [0, 0, image.columns, image.rows])
    end
  end

end
