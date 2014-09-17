# Given an image, return an ordered array of detectable barcodes
#require 'jruby'
#require 'zxing'

class Sqed::BarcodeParser

  attr_accessor :image, :barcodes

  def initialize(image)
    @image = image

    @barf_codes = []
    @barf_codes = bar_codes
    @b = 1    #breakpoint

  end

  def bar_codes
    # process the images, spit out the barcodes
    # return ZXing.decode_all(@image)   #['ABC 123', 'DEF 456']
    a = `/usr/local/Cellar/zbar/0.10_1/bin/zbarimg ~/src/sqed/spec/support/files/test_barcode.JPG`
    b = a.split("\n")
    f = 'SessionID_BarcodeImage.JPG'
    i = @image[:image]
    i.write(f)
    c = `/usr/local/Cellar/zbar/0.10_1/bin/zbarimg #{f}`
    d = c.split("\n")
    return d
  end

end
