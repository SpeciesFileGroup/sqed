 include Magick

 # Recieve a image (memory) that has already been cropped.
 #
 # May be useful 
 #   # http://www.imagemagick.org/Usage/morphology/#intro
 # 
 # 0,0  x,0
 #      0 | 1 
 #  0,y --|--
 #      2 | 3
 #
 # A class to split an Image into 4 pieces, that's all.
class Sqed
  class QuadrantParser

   QUADRANTS = {
     0 => :identfier,
     1 => :specimen,
     2 => :labels,
     3 => :standards
   }

   # may need to split @image to @working_image, @original_image 
   attr_accessor :initial_image
   attr_accessor :images
   attr_accessor :center_x
   attr_accessor :center_y 

   # image = ImageList.new('white_black.jpg')
   def initialize(image: image)
     @initial_image = image
     @images = []
   end

   # generates 4 images
   # http://www.imagemagick.org/Usage/crop/#crop_quad
   # store them in memory in @images[0..3]
   def divide_image(axes_method: :centered)
     find_axes(axes_method: axes_method)

     @images[0] = @initial_image.crop(0, 0, @center_x, @center_y)
     @images[1] = @initial_image.crop(@center_x, 0 , @center_x, @center_y)
     @images[2] = @initial_image.crop(0, @center_y , @center_x, @center_y)
     @images[3] = @initial_image.crop(@center_x, @center_y , @center_x, @center_y)

     # Spilt the images based no the axes, assign them to @images
     # Code here...
   end

   def find_axes(axes_method: :centered ) 
     @center_x, @center_y = self.send("axes_by_#{axes_method}")
   end
 
   # Computes center of the image only
   # returns x int, y int 
   def axes_by_centered
     return [@initial_image.columns/2, @initial_image.rows/2]
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

   def image_from_quadrant(quadrant = 0)
     divide_image if !@images[0] 
     @images[quadrant] 
   end

  end
end
