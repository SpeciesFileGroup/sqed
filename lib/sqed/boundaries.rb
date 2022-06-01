
class Sqed

  # An Sqed::Boundaries is a simple wrapper for a hash that contains the co-ordinates for each section of a layout.
  #
  # Layouts are Hashes defined in EXTRACTION_PATTERNS[<pattern>][<layout>]
  #
  class Boundaries
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

  # @return [Boolean] whether or not the last method to populate this object
  # executed to completion
  attr_accessor :complete

  def initialize(layout = nil)
    raise Sqed::Error, 'unrecognized layout' if layout && !SqedConfig::LAYOUTS.include?(layout)
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

  # @return [Sqed::Boundaries instance]
  #   the idea here is to create a deep copy of self, offsetting by boundary
  #   as we go
  def offset(boundary)
    b = Sqed::Boundaries.new
    (0..coordinates.length - 1).each do |i|
      b.set(i,
            [(x_for(i) + boundary.x_for(0)),
             (y_for(i) + boundary.y_for(0)),
             width_for(i),
             height_for(i)])
    end
    b.complete = complete
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

  def populated?
    each do |index, coords|
      coords.each do |c|
        return false if c.nil?
      end
    end
    true
  end

  def zoom(width_factor, height_factor)
    coordinates.keys.each do |i|
      set(i, [
          (x_for(i).to_f * width_factor).to_i,
          (y_for(i).to_f * height_factor).to_i,
          (width_for(i).to_f * width_factor).to_i,
          (height_for(i).to_f * height_factor).to_i
      ])
    end
  end

  end
end
