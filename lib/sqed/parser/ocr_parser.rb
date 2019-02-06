require 'rtesseract'

# We use tempfile because Rtesseract doesn't work directly with ImageMagic::Image (any longer... apparently, maybe)
# https://ruby-doc.org/stdlib-2.6.1/libdoc/tempfile/rdoc/Tempfile.html
require 'tempfile'

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
class Sqed::Parser::OcrParser < Sqed::Parser

  TYPE = :text

  # Other experimented with default params
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

  # Tesseract parameters default/specific to section type, 
  # default is merged into the type
  SECTION_PARAMS = {
    default: {
      psm: 3
    },
    annotated_specimen: {
      # was 45, significantly improves annotated_specimen for odontates
      edges_children_count_limit: 3000 
    },
    identifier: {
      psm: 1,
      # tessedit_char_whitelist: '0123456789'
      #  edges_children_count_limit: 4000
    },
    curator_metadata: {
      psm: 3
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
  }.freeze

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
  def get_text(section_type: :default)
    img = image

    # resample if an image 4"x4" is less than 300dpi 
    if img.columns * img.rows < 144000
      img = img.resample(300)
    end

    params = SECTION_PARAMS[:default].dup
    params.merge!(SECTION_PARAMS[section_type])

    # May be able to overcome this hacky kludge messe with providing `processor:` to new
    file = Tempfile.new('foo1')
    begin
      file.write(image.to_blob)
      file.rewind
      @extracted_text = RTesseract.new(file.path, params).to_s&.strip
      file.close
    ensure
      file.close
      file.unlink   # deletes the temp file
    end

    if @extracted_text == ''
      file = Tempfile.new('foo2')
      begin
        file.write(img.dup.white_threshold(245).to_blob)
        file.rewind
        @extracted_text = RTesseract.new(file.path, params).to_s&.strip
        file.close
      ensure
        file.close
        file.unlink   # deletes the temp file
      end
    end

    if @extracted_text == ''
      file = Tempfile.new('foo3')
      begin
        file.write(img.dup.quantize(256,Magick::GRAYColorspace).to_blob)
        file.rewind
        @extracted_text = RTesseract.new(file.path, params).to_s&.strip
        file.close
      ensure
        file.close
        file.unlink   # deletes the temp file
      end
    end

    @extracted_text
  end

end
