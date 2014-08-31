require 'RMagick'
require 'rtesseract'
require 'byebug'

# https://gist.github.com/henrik/1967035 (took 8 minutes to brew in stall)

@initial_image =  Magick::Image.read('spec/support/files/test_ocr0.jpg').first
#@initial_image =  Magick::Image.read('spec/support/files/test2.jpg').first

@cropped_image = nil
# @stage_locator = stage_locator
@x_offset = @initial_image.columns/2
@y_offset = @initial_image.rows/2  # half the height
@width = @x_offset # half the width to start off
@height = @initial_image.rows/2  # half the height

#WindowCropper.crop(@x_offset, @y_offset, @width, @height)

@cropped_image = @initial_image.crop(@x_offset, @y_offset, @width, @height)
@cropped_image.write('croppedImage.JPG')

@tess_image = RTesseract.read('croppedImage.JPG', lang: "eng") do |img|
  img = img.white_threshold(255)
  img = img.quantize(256, Magick::GRAYColorspace)
end

puts( @tess_image.to_s )
