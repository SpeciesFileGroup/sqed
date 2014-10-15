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
 #
 #  a = Sqed::QuadrantParser.new(image: <some_image>)
 #  a.images[0]
 #
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

   # Generates 4 images based on the axis finding method.
   # store them in memory in @images[0..3]
   def divide_image(axes_method: :centered)
     find_axes(axes_method: axes_method)
 
     # See alternative? : http://www.imagemagick.org/Usage/crop/#crop_quad
     @images[0] = @initial_image.crop(0, 0, @center_x, @center_y)
     @images[1] = @initial_image.crop(@center_x, 0 , @center_x, @center_y)
     @images[2] = @initial_image.crop(0, @center_y , @center_x, @center_y)
     @images[3] = @initial_image.crop(@center_x, @center_y , @center_x, @center_y)

     write_quadrants
   end

   def write_quadrants
     (0..3).each do |i|
       @images[i].write("foo_#{i}.jpg")
     end
   end

   def find_axes(axes_method: :centered ) 
     @center_x, @center_y = self.send("axes_by_#{axes_method}")
   end
 
   # Computes by center of the image only
   def axes_by_centered
     return [@initial_image.columns/2, @initial_image.rows/2]
   end

   # Detects green lines 
   # returns x int, y int 
   # TODO: @jrflood
   def axes_by_green_line
    return [false, false] 
   end

   # Finds a center marker (shape/etc. to be determined, likely a spherical object in contrast in "center")
   # returns x int, y int 
   # TODO: @jrflood
   def axes_by_center_marker
    return [false, false] 
   end

   # Return an image from a quadrant.  Divides the 
   # image if it hasn't been previously divided.
   def image_from_quadrant(quadrant = 0)
     raise if quadrant < 0 or quadrant > 3  # range check
     divide_image if @images.empty?
     @images[quadrant] 
   end

  end
end
