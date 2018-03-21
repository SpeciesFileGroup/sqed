# encoding: UTF-8
#
# Given a single image return all text in that image.
#
# For reference 
#   http://misteroleg.wordpress.com/2012/12/19/ocr-using-tesseract-and-imagemagick-as-pre-processing-task/
#   https://code.google.com/p/tesseract-ocr/wiki/FAQ
#   http://www.sk-spell.sk.cx/tesseract-ocr-parameters-in-302-version
#
# "There is a minimum text size for reasonable accuracy. 
# You have to consider resolution as well as point size. 
# Accuracy drops off below 10pt x 300dpi, rapidly below 8pt x 300dpi. 
# A quick check is to count the pixels of the x-height of your characters. 
# (X-height is the height of the lower case x.) 
# At 10pt x 300dpi x-heights are typically about 20 pixels, although this
# can vary dramatically from font to font. 
# Below an x-height of 10 pixels, you have very little chance of accurate results, 
# and below about 8 pixels, most of the text will be "noise removed". 
#
require 'rtesseract' 

class Sqed::Parser::OcrParser < Sqed::Parser

  TYPE = :text

  # Tesseract parameters default/specific to section type, 
  # default is merged into the type
  SECTION_PARAMS = {
    default: {
      psm: 3,
#      classify_debug_level: 5,
#      lang: 'eng', 
#      load_system_dawg: 0,
#      load_unambig_dawg: 0,
#      load_freq_dawg: 0,
#      load_fixed_length_dawgs: 0,
#      load_number_dawg: 0,
#      load_punc_dawg: 1, ## important
#      load_unambig_dawg: 1,
#      chop_enable: 0,
#     enable_new_segsearch: 1,
#     tessedit_debug_quality_metrics: 1,
#     tessedit_write_params_to_file: 'tmp/ocr_config_file.txt',
#     tessedit_write_images: 1,
#     equationdetect_save_merged_image: 1,
#     tessedit_dump_pageseg_images: 1,
#     equationdetect_save_bi_image: 1
    },
    annotated_specimen: {
      edges_children_count_limit: 3000 # was 45, significantly improves annotated_specimen for odontates
    },
    identifier: {
      psm: 1,
      # tessedit_char_whitelist: '0123456789'
      #  edges_children_count_limit: 4000
    }, 
    curator_metadata: {
    },
    labels: {
      psm: 3, # may need to be 6
    },
    determination_labels: {
      psm: 3
    },
    other_labels: {
      psm: 3
    },
    collecting_event_labels: {
      psm: 3
    }
  }

  # the text extracted from the image
  attr_accessor :text

  # future consideration 
  # def enhance_image(img)
  # get potential border pixel color (based on quadrant?)
  # new_color = img.pixel_color(1, 1)

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
  # img.write('foo4.jpg') 
  # img = img.equalize #(32, Magick::GRAYColorspace)
  # img.write('foo5.jpg') 
  # #img.write('foo3.jpg') 
  #
  # img.write('foo.jpg') 
  # img = img.white_threshold(245)
  # img
  # end
 
  # @return [String]
  #   the ocr text 
  def text(section_type: :default)
    img = image 
 
    # resample if an image 4"x4" is less than 300dpi 
    if img.columns * img.rows < 144000
      img = img.resample(300)
    end

    params = SECTION_PARAMS[:default]
    params.merge!(SECTION_PARAMS[section_type])

    r = RTesseract.new(img, params) 
    @text = r.to_s.strip

    if @text == ""
      img = img.white_threshold(245)
      r = RTesseract.new(img, params) 
      @text = r.to_s.strip
    end

    if @text == ""
      img = img.quantize(256,Magick::GRAYColorspace)
      r = RTesseract.new(img, params) 
      @text = r.to_s.strip
    end

    @text
  end

end
