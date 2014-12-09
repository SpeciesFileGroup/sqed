require 'RMagick'

# Return four equal qundrants, no parsing through the image

class Sqed::BoundaryFinder::CrossFinder < Sqed::BoundaryFinder

 def initialize(image: image, is_border_proc: nil, min_ratio: MIN_CROP_RATIO, layout: nil, stage_boundary: stage_boundary)
   @image = image
    find_edges 
 end

 def find_edges
   width = @image.columns / 2
   height = @image.rows / 2

   boundaries.coordinates[0] = [0, 0, width, height] 
   boundaries.coordinates[1] = [width, 0, width, height] 
   boundaries.coordinates[2] = [width, height, width, height] 
   boundaries.coordinates[3] = [0, height, width, height] 
 end

end
