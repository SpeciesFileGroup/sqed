# encoding: UTF-8
#
# Base class for Parsers
#
class Sqed::Parser
  attr_accessor :image

  def initialize(image)
    @image = image 
    raise 'no image provided to parser' if @image && !(@image.class.name == 'Magick::Image')
  end

  # must be provided in subclasses
  def text
    nil
  end

end
