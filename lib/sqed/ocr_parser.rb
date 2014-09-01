# encoding: UTF-8

# stub 
=begin
  
          # maybe:
          # http://misteroleg.wordpress.com/2012/12/19/ocr-using-tesseract-and-imagemagick-as-pre-processing-task/
           class Sqed::OcrParser::Identifier
              # as parent, but narrow down logic to focus on known patterns

           class Sqed::OcrParser::Labels

          # maybe: some registration
=end 

# Given a single image return all text

require 'rtesseract' 

class Sqed
  class OcrParser

    attr_accessor :image, :text

    def initialize(image)
      @image = image 
    end

    def text
      r = RTesseract.new(@image) do |img|
        img = img.white_threshold(255)
        img = img.quantize(256, Magick::GRAYColorspace)
      end
      @text = r.to_s 
    end

    # Need to provide tuning methods here, i.e. image transormations that facilitate OCR

  end
end
