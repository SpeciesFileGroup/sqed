# An Sqed::Boundaries is a simple wrapper for a hash that contains the co-ordinates for each section of a layout.

# Layouts are Hashes defined in EXTRACTION_PATTERNS[<pattern>][<layout>]
# 
class Sqed::Boundaries 
  include Enumerable

  # stores a hash
  # References the section by integer index!
  # In the pattern integer => [x1,y1, width, height] (ImageMagick convention rectangle descriptors)
  # e.g.
  #   0 => [10,10,40,40]
  attr_reader :coordinates

  # An EXTRACTION_PATTERN layout
  attr_accessor :layout

  def initialize(layout = nil)
    @layout = layout
    @coordinates = {}
      initialize_coordinates if !@layout.nil?
  end

  def initialize_coordinates
    SqedConfig::LAYOUTS[@layout].each do |k|
      @coordinates.merge!(k => [nil, nil, nil, nil] )
    end
  end

  def for(section)
    @coordinates[section]
  end

  def each(&block)
    @coordinates.each do |section_index, coords|
      block.call([section_index, coords])
    end
  end

  def x_for(index)
    @coordinates[index][0]
  end

  def y_for(index)
    @coordinates[index][1]
  end

  def width_for(index)
    @coordinates[index][2]
  end

  def height_for(index)
    @coordinates[index][3]
  end

end
