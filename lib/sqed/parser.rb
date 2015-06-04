# encoding: UTF-8
#
# Base class for Parsers
#
class Sqed::Parser
  attr_accessor :image

  def initialize(image)
    @image = image 
  end

end
