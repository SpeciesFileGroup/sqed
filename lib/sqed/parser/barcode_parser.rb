# Given an image, return an ordered array of detectable barcodes
#
# !! DOES NOTHING !!
#
class Sqed::Parser::BarcodeParser < Sqed::Parser

  TYPE = :barcode

  attr_accessor :barcode

  def initialize(image)
    super
    @image = image
  end

  def barcode
    @barcode ||= get_barcode
    @barcode
  end

  # Uses the same enging as zbarimg that you can install with brew (zbarimg)
  #
  def get_code_128
    nil # ZXing.decode @image.filename
  end

  # try a bunch of options, organized by most common,  give the first hit
  def get_barcode
    [get_code_128].compact.first
  end

 #def get_datamatrix
 #  https://github.com/srijan/ruby-dmtx
 #end

  # alias to a universal method
  def get_text(section_type: :default)
    barcode
  end


end
