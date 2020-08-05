# encoding: UTF-8
#
# Base class for Parsers
#
class Sqed::Parser

  attr_accessor :image

  attr_accessor :extracted_text

  def initialize(image)
    raise Sqed::Error, 'no image passed to parser' if image.nil?
    raise Sqed::Error, 'image is not a Magick::Image' if !(image.class.name == 'Magick::Image')
    @image = image
  end

end
