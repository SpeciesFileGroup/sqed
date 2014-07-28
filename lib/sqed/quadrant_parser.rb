 include Magick

 # May be useful 
 #   # http://www.imagemagick.org/Usage/morphology/#intro
 # 
 # 0,0  x,0
 #      1 | 2 
 #  0,y --|--
 #      3 | 4
 #
 # A class to split an Image into 4 pieces, that's all.
class Sqed::QuadrantParser

   QUADRANTS = {
     1 => :identfier,
     2 => :specimen,
     3 => :labels,
     4 => :standards
   }

   # may need to split @image to @working_image, @original_image 
   attr_accessor :image
   attr_accessor :images
   attr_accessor :center_x
   attr_accessor :center_y 

   # image = ImageList.new('white_black.jpg')
   def initialize(image)
     @image = image
     @images = []
   end

   # generates 4 images
   # http://www.imagemagick.org/Usage/crop/#crop_quad
   # store them in memory in @images[0..3]
   def divide_image(axes_method: :centered, crop_method: :trim)
     autocrop(crop_method)
     find_axes(axes_method)

     # Spilt the images based no the axes, assign them to @images
     # Code here...
   end


   def find_axes(axes_method: :centered) 
     @center_x, @center_y = self.send("axes_by_#{method}")
   end

   def autocrop(crop_method: :trim ) 
     @image = self.send("crop_by_#{method}")
   end

   # Returns an image that has been cropped down
   def crop_by_trim
     # use -shave option with crop to just trim down the image 
   end

   #  def crop_by_border_find
   #    #https://gist.github.com/EmmanuelOga/2476153 (does't work ?!)
   #  end 
 
   # Computes center of the image only
   # returns x int, y int 
   def axes_by_centered
    return [false, false]
   end

   # Detects green lines 
   # returns x int, y int 
   def axes_by_green_line
    return [false, false] 
   end

   # Finds a center marker (shape/etc. to be determined, likely a spherical object in contrast in "center") 
   # returns x int, y int 
   def axes_by_center_marker
    return [false, false] 
   end

end
