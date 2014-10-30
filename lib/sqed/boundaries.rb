# An Squed::Boundaries is a simple wrapper for a hash that contains the co-ordinates for each section of a layout.

# Layouts are Hashes defined in EXTRACTION_PATTERNS[<pattern>][<layout>]
# 
class Sqed::Boundaries 
  include Enumerable

  attr_accessor :coordinates 

  def initialize(layout)
    layout.keys.each do |k|
      @coordinates = {
        k => [nil, nil, nil, nil], # x1, y1, x2, y2 (top left, bottom right)
      } 
    end

    def coordinates_for_section(section)
      @coordinates[section]
    end

    def each(&block)
      @coordinates.each do |section_index, coords|
        block.call([section_index, coords])
      end
    end

  end
end
