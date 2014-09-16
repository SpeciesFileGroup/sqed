# Given an image, return an ordered array of detectable barcodes
require jruby
require zxing

class Sqed::BarcodParser

  attr_accessor :image, :barcodes

  def initialize(image)
    @image = image
    @image =
    @barcodes = []
  end

  def barcodes 
    # process the images, spit out the barcodes
    return ['ABC 123', 'DEF 456']
  end

end
