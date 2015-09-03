require 'rmagick'

# Return four equal quadrants, no parsing through the image
#
class Sqed::BoundaryFinder::CrossFinder < Sqed::BoundaryFinder

  def initialize(image: image, use_thumbnail: true)
    @img = image
    @use_thumbnail = use_thumbnail
 
    if use_thumbnail
      @original_image = @img
      @img = thumbnail
    end  
  
    find_edges 
  end

  def find_edges
    width = @img.columns / 2
    height = @img.rows / 2

    boundaries.coordinates[0] = [0, 0, width, height] 
    boundaries.coordinates[1] = [width, 0, width, height] 
    boundaries.coordinates[2] = [width, height, width, height] 
    boundaries.coordinates[3] = [0, height, width, height] 
    boundaries.complete = true

    if @use_thumbnail
      @img = @original_image
      zoom_boundaries
      @original_image = nil
    end
  end

end
