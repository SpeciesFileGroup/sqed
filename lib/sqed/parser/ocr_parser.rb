# encoding: UTF-8
#
# Given a single image return all text in that image.
#
# For past reference http://misteroleg.wordpress.com/2012/12/19/ocr-using-tesseract-and-imagemagick-as-pre-processing-task/
#
require 'rtesseract' 

class Sqed::Parser::OcrParser < Sqed::Parser

  TYPE = :text

  # the text extracted from the image
  attr_accessor :text

  # https://code.google.com/p/tesseract-ocr/wiki/FAQ
  def text
    img = @image #.white_threshold(245)

    # @jrflood: this is where you will have to do some research, tuning images so that they can be better ocr-ed,
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


    # From https://code.google.com/p/tesseract-ocr/wiki/FAQ
    # " There is a minimum text size for reasonable accuracy. You have to consider resolution as well as point size. Accuracy drops off below 10pt x 300dpi, rapidly below 8pt x 300dpi. A quick check is to count the pixels of the x-height of your characters. (X-height is the height of the lower case x.) At 10pt x 300dpi x-heights are typically about 20 pixels, although this can vary dramatically from font to font. Below an x-height of 10 pixels, you have very little chance of accurate results, and below about 8 pixels, most of the text will be "noise removed". 


    # http://www.sk-spell.sk.cx/tesseract-ocr-parameters-in-302-version
    # doesn't supprot outputbase
    r = RTesseract.new(img, lang: 'eng', psm: 1, 
                       load_system_dawg: 0,
                       tessedit_debug_quality_metrics: 1,
                       load_freq_dawg: 1 ,
                       chop_enable: 1,
                       tessedit_write_images: 1,
                       equationdetect_save_merged_image: 1,
                       tessedit_dump_pageseg_images: 1,
                       equationdetect_save_bi_image: 1,
                       load_unambig_dawg: 0,
                       tessedit_write_params_to_file: 'tmp/ocr_config_file.txt' ) # psm: 3,

    # img = img.white_threshold(245)

    @text = r.to_s.strip 
  end

  # Need to provide tuning methods here, i.e. image transormations that facilitate OCR

end
