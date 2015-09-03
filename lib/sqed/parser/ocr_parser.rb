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
    # img = img.posterize(levels=2, dither=false)
    # img.write('foo1.jpg')
    img = img.quantize(1024, Magick::GRAYColorspace, Magick::NoDitherMethod)
    # hist = img.color_histogram
    line_scan(image: img, scan: :columns)
    # img = img.quantize(16, Magick::GRAYColorspace, NoDitherMethod)
    # img = img.quantize(2, Magick::GRAYColorspace, NoDitherMethod)
    img.write('foo1.jpg')
    # img = img.sharpen(1.0, 0.2)
    # img.write('foo2.jpg')
    # border_color = img.pixel_color(img.columns - 1, img.rows - 1)
    # img = img.color_floodfill(img.columns - 1, img.rows - 1, new_color)
    # img.write('tmp/foo4.jpg')
    # img = img.quantize(2, Magick::GRAYColorspace)
    #img = img.threshold(0.5)
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

  # Need to provide tuning methods here, i.e. image transformations that facilitate OCR

  def line_scan(image: image, scan: :columns)
    range = image.columns - 1 if scan == :columns
    range = image.rows - 1 if scan == :rows
    (0..range).each do |s|
      # Create a sample image a single pixel wide/tall
      if scan == :rows  # range over y=0 to img.rows
        # j = image.get_pixels(0, s, image.columns, 1)
        j = image.crop(0, s, image.columns, 1)
      elsif scan == :columns
        # j = image.get_pixels(s, 0, 1, image.rows)
        j = image.crop(s, 0, 1, image.rows)
      else
        raise
      end
    hist = j.color_histogram
    hist.keys.sort!
    j = j.quantize(3, Magick::GRAYColorspace, Magick::NoDitherMethod)
    hist = j.color_histogram
    u = s
    end

  end

  # threshold detector/corrector - preprocess to gray
  #   scan a line (h/v) to find distribution, then convert pixels below threshold to black, above to white
  def self.threshold_finder(image: image, sample_subdivision_size: 10, sample_cutoff_factor: nil, scan: :columns, boundary_color: :green)
    border_hits = {}
    samples_to_take = (image.send(scan) / sample_subdivision_size).to_i - 1

    (0..image.columns-1).each do |s|
      # Create a sample image a single pixel tall
      if scan == :rows  # range over y=0 to img.rows
        j = image.get_pixels(0, s, image.columns, 1)
      elsif scan == :columns
        j = image.get_pixels(s, 0, 1, image.rows)
      else
        raise
      end

      j.each_pixel do |pixel, c, r|
        index = ( (scan == :rows) ? c : r)

        # Our hit metric is dirt simple, if there is some percentage more of the boundary_color than the others, count + 1 for that column
        if send("is_#{boundary_color}?", pixel)
          # we have already hit that column previously, increment
          if border_hits[index]
            border_hits[index] += 1
            # initialize the newly hit column 1
          else
            border_hits[index] = 1
          end
        end
      end
    end

    return nil if border_hits.length < 2

    if sample_cutoff_factor.nil?
      cutoff = max_difference(border_hits.values)
    else
      cutoff = (samples_to_take * sample_cutoff_factor).to_i
    end

    frequency_stats(border_hits, cutoff)
  end

  def self.is_green?(pixel)
    (pixel.green > pixel.red*1.2) && (pixel.green > pixel.blue*1.2)
  end

  def self.is_blue?(pixel)
    (pixel.blue > pixel.red*1.2) && (pixel.blue > pixel.green*1.2)
  end

  def self.is_red?(pixel)
    (pixel.red > pixel.blue*1.2) && (pixel.red > pixel.green*1.2)
  end

  def self.is_black?(pixel)
    black_threshold = 65535*0.15    #tune for black
    (pixel.red < black_threshold) &&  (pixel.blue < black_threshold) &&  (pixel.green < black_threshold)
  end

  # Takes a frequency hash of position => count key/values and returns
  # the median position of all positions that have a count greater than the cutoff
  def self.frequency_stats(frequency_hash, sample_cutoff = 0)
    return nil if sample_cutoff.nil? ||  sample_cutoff < 1
    hit_ranges = []

    frequency_hash.each do |position, count|
      if count >= sample_cutoff
        hit_ranges.push(position)
      end
    end

    return nil if hit_ranges.size < 3

    # we have to sort because the keys (positions) we examined came unordered from a hash originally
    hit_ranges.sort!

    # return the position exactly in the middle of the array
    [hit_ranges.first, hit_ranges[(hit_ranges.length / 2).to_i], hit_ranges.last]
  end

  # Returns an Integer, the maximum of the pairwise differences of the values in the array
  # For example, given
  #   [1,2,3,9,6,2,0]
  # The resulting pairwise array is
  #   [1,1,6,3,4,2]
  # The max (value returned) is
  #   6
  def self.max_pairwise_difference(array)
    (0..array.length-2).map{|i| (array[i] - array[i+1]).abs }.max
  end

  def self.max_difference(array)
    array.max - array.min
  end

  def self.derivative_signs(array)
    (0..array.length-2).map { |i| (array[i+1] - array[i]) <=> 0 }
  end

  def self.derivative(array)
    (0..array.length-2).map { |i| array[i+1] - array[i] }
  end

end
