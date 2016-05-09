require 'rmagick'

# Return four equal quadrants, no parsing through the image
#
class Sqed::BoundaryFinder::CrossFinder < Sqed::BoundaryFinder

  def initialize(target_image: image)
    @image = target_image
    find_edges 
  end

  def find_edges
    width = image.columns / 2
    height = image.rows / 2

    boundaries.coordinates[0] = [0, 0, width, height] 
    boundaries.coordinates[1] = [width, 0, width, height] 
    boundaries.coordinates[2] = [width, height, width, height] 
    boundaries.coordinates[3] = [0, height, width, height] 
    boundaries.complete = true
  end

end
