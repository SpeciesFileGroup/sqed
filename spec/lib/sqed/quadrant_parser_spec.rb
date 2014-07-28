require 'spec_helper'

describe Sqed::QuadrantParser do

  skip '#find_axes(method = :centered)' 

end 

# include Magick

# # May be useful 
# #   # http://www.imagemagick.org/Usage/morphology/#intro
# # 
# # 0,0  x,0
# #      1 | 2 
# #  0,y --|--
# #      3 | 4
# #
# # A class to split a staged specimen into 4 pieces
# class 

#   QUADRANTS = {
#     1 => :identfier,
#     2 => :specimen,
#     3 => :labels,
#     4 => :standards
#   }

#   attr_accessor :image
#   attr_accessor :images
#   attr_accessor :center_x
#   attr_accessor :center_y 

#   # image = ImageList.new('white_black.jpg')
#   def initialize(image)
#     @image = image
#     @images = []
#   end

#   def find_axes(method = :centered) 
#     self.send("axes_by_#{method}")
#   end

#   def autocrop(method = :trim ) 
#     self.send("crop_by_#{method}")
#   end

#   def crop_by_trim
#     # use -shave option with crop to just trim down the image 
#   end

#   #  def crop_by_border_find
#   #    #https://gist.github.com/EmmanuelOga/2476153 (does't work ?!)
#   #  end 

#   def axes_by_centered
#     # returns x int, y int 
#   end

#   def axes_by_green_line
#   # option A along green lines
#   # returns x int, y int 
#   end

#   def axes_by_center_marker
#   end

#   def divide_image(x = 1, y = 1)   
#     # generates 4 images
#     # http://www.imagemagick.org/Usage/crop/#crop_quad
#     # store them in memory in @images[0..3]
#   end

# end
