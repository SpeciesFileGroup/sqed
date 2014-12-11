# Given an image, return an ordered array of detectable barcodes

class Sqed::Parser::BarcodeParser < Sqed::Parser
  attr_accessor :barcodes

  def initialize(image)
    super
    @barcodes = bar_codes
  end

  def bar_codes
    # process the images, spit out the barcodes
    # return ZXing.decode_all(@image)   #['ABC 123', 'DEF 456']
    # a = `/usr/local/Cellar/zbar/0.10_1/bin/zbarimg ~/src/sqed/spec/support/files/test_barcode.JPG`
    # b = a.split("\n")
    f = 'SessionID_BarcodeImage.JPG'
    i = @image[:image]
    if i.nil?
      i = @image
    end
    i.write("tmp/#{f}")
    c = `/usr/local/Cellar/zbar/0.10_1/bin/zbarimg #{f}`
    d = c.split("\n")
    return d
  end

end
