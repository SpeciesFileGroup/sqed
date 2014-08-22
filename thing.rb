require 'rtesseract'
require 'rmagick'

@initial_image =  Magick::Image.read('testImage.JPG.jpeg').first
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
@tess_image = RTesseract.new('croppedImage.JPG')
puts(@tess_image.to_s)
