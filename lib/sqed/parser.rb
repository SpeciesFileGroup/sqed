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

  # TODO: is this required?!j
  # must be provided in subclasses
  def text(section_type: :default)
    nil
  end

end
