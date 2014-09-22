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
      img = @image #.white_threshold(245)
    
      # @jrflood: this is where you will have to do some research, tuning images so that they can be better ocr-ed,
      # all of these methods are from RMagick.
      # get potential border pixel color (based on quadrant?)
      new_color = img.pixel_color(1, 1)
      # img = img.scale(2)
      # img.write('foo0.jpg.jpg')
      # img = img.enhance
      # img = img.enhance
      # img = img.enhance
      # img = img.enhance
      # img.write('foo1.jpg')
      # img = img.quantize(8, Magick::GRAYColorspace)
      # img.write('foo1.jpg')
      # img = img.sharpen(1.0, 0.2)
      # img.write('foo2.jpg')
      border_color = img.pixel_color(img.columns - 1, img.rows - 1)
      img = img.color_floodfill(img.columns - 1, img.rows - 1, new_color)
      img.write('foo4.jpg')
      # img = img.quantize(2, Magick::GRAYColorspace)
      # #img = img.threshold(0.5)
      # img.write('foo4.jpg') # for debugging purposes, this is the image that is sent to OCR
      # img = img.equalize #(32, Magick::GRAYColorspace)
      # img.write('foo5.jpg') # for debugging purposes, this is the image that is sent to OCR
      # #img.write('foo3.jpg') # for debugging purposes, this is the image that is sent to OCR
      #
      # img.write('foo.jpg') # for debugging purposes, this is the image that is sent to OCR

      r = RTesseract.new(img, lang: 'eng', psm: 3) 
     

      # img = img.white_threshold(245)
      
      @text = r.to_s 
    end

    # Need to provide tuning methods here, i.e. image transormations that facilitate OCR

  end
end
