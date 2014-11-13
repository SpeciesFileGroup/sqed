require 'RMagick'

# Find a (mostly) solid-color cross delineating quadrants.  Adapted from Emmanuel Oga/autocrop.rb

class Sqed::BoundaryFinder::CrossFinder < Sqed::BoundaryFinder

  # enumerate read-only parameters involved, accessible either as  <varname> or @<varname>
  attr_reader  :is_border

  def boundaries
    b = Sqed::Boundaries.new( SqedConfig::EXTRACTION_PATTERNS[:stage][:layout] )
    b.coordinates[:stage] = [x0, y0, width, height]
    b
  end

  private
 

end
