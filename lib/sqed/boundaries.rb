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

  # A symbol from Sqed::Config::LAYOUTS.keys 
  #   :right_t
  attr_accessor :layout

  # Boolean, whether or not the last method to populate this object passed fully
  attr_accessor :complete

  def initialize(layout = nil)
    raise 'unrecognized layout' if layout && !SqedConfig::LAYOUTS.include?(layout)
    @complete = false

    @layout = layout
    @coordinates = {}
    initialize_coordinates if !@layout.nil?
  end

  def initialize_coordinates
    SqedConfig::LAYOUTS[@layout].each do |k|
      @coordinates.merge!(k => [nil, nil, nil, nil] )
    end
  end

  def offset(boundary)
    b = Sqed::Boundaries.new()    # the idea here is to create a deep copy of self, offsetting by boundary as we go
    (0..self.coordinates.length - 1).each do |i|
      b.coordinates[i] = []  # create the instance of the i-th coordinate, then populate it
      b.coordinates[i][0] = self.x_for(i) + boundary.x_for(0)
      b.coordinates[i][1] = self.y_for(i) + boundary.y_for(0)
      b.coordinates[i][2] = self.width_for(i)
      b.coordinates[i][3] = self.height_for(i)
    end
    b.complete = self.complete
    b
  end

  def for(section)
    @coordinates[section]
  end

  def each(&block)
    @coordinates.each do |section_index, coords|
      block.call([section_index, coords])
    end
  end

  # Overrides Enumerable
  def count
    @coordinates.length
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

  def set(index, coordinates)
    @coordinates[index] = coordinates
  end


end
