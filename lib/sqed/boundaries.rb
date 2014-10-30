# An Squed::Boundaries is a simple wrapper for a hash that contains the co-ordinates for each section of a layout.

# Layouts are Hashes defined in EXTRACTION_PATTERNS[<pattern>][<layout>]
# 
class Sqed::Boundaries 
  include Enumerable

  # References the section by section name, not index!
  # In the pattern section_type: [x1,y1, width, height]
  # e.g.
  #   stage: [10,10,40,40]
  attr_reader :coordinates

  # An EXTRACTION_PATTERN layout
  attr_accessor :layout

  def initialize(layout = nil)
    @layout = layout
    @coordinates = {}
    if @layout
      initialize_coordinates
    else
      @layout = {}
    end   
  end

  def initialize_coordinates
    @layout.keys.each do |k|
      @coordinates.merge!(@layout[k] => [nil, nil, nil, nil] )
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

end
