# encoding: UTF-8
#
# Given a single image return all text in that image.
#
# For past reference http://misteroleg.wordpress.com/2012/12/19/ocr-using-tesseract-and-imagemagick-as-pre-processing-task/
#
require 'rtesseract' 

class Sqed::Parser::OcrParser < Sqed::Parser

  # the text extracted from the image
  attr_accessor :text

  def text
    img = @image #.white_threshold(245)

    # @jrflood: this is where you will have to do some research, tuning images so that they can be better ocr-ed,
    # all of these methods are from RMagick.
    # get potential border pixel color (based on quadrant?)
    new_color = img.pixel_color(1, 1)
    # img = img.scale(2)
    # img.write('foo0.jpg.jpg')
    # img = img.enhance
    # img.write('foo1.jpg')
    # img = img.quantize(8, Magick::GRAYColorspace)
    # img.write('foo1.jpg')
    # img = img.sharpen(1.0, 0.2)
    # img.write('foo2.jpg')
    # border_color = img.pixel_color(img.columns - 1, img.rows - 1)
    # img = img.color_floodfill(img.columns - 1, img.rows - 1, new_color)
    # img.write('tmp/foo4.jpg')
    # img = img.quantize(2, Magick::GRAYColorspace)
    # #img = img.threshold(0.5)
    # img.write('foo4.jpg') # for debugging purposes, this is the image that is sent to OCR
    # img = img.equalize #(32, Magick::GRAYColorspace)
    # img.write('foo5.jpg') # for debugging purposes, this is the image that is sent to OCR
    # #img.write('foo3.jpg') # for debugging purposes, this is the image that is sent to OCR
    #
    # img.write('foo.jpg') # for debugging purposes, this is the image that is sent to OCR

    r = RTesseract.new(img, lang: 'eng', psm: 3, )

    # img = img.white_threshold(245)

    @text = r.to_s.strip 
  end

  # Need to provide tuning methods here, i.e. image transormations that facilitate OCR

end
