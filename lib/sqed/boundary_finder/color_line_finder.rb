require 'RMagick'

# This was "green" line finder attempting to be agnostic; now it is reworked to be color-specific line finder
#
class Sqed::BoundaryFinder::ColorLineFinder < Sqed::BoundaryFinder

  def initialize(image: image, layout: layout, boundary_color: :green)
    super(image: image, layout: layout)
    raise 'No layout provided.' if @layout.nil?
    @boundary_color = boundary_color
    find_bands
  end

  private

  def find_bands
    case @layout    # boundaries.coordinates are referenced from stage image

    when :vertical_split    # can vertical and horizontal split be re-used to do cross cases?
      t = Sqed::BoundaryFinder.color_boundary_finder(image: img, boundary_color: @boundary_color)  #detect vertical division, green line
      return if t.nil?
      boundaries.set(0, [0, 0, t[0], img.rows])  # left section of image
      boundaries.set(1, [t[2], 0, img.columns - t[2], img.rows])  # right section of image
      boundaries.complete = true

    when :horizontal_split
      t = Sqed::BoundaryFinder.color_boundary_finder(image: img, scan: :columns, boundary_color: @boundary_color)  # set to detect horizontal division, (green line)
      return if t.nil?
      boundaries.set(0, [0, 0, img.columns, t[0]])  # upper section of image
      boundaries.set(1, [0, t[2], img.columns, img.rows - t[2]])  # lower section of image
      boundaries.complete = true
      # boundaries.coordinates[2] = [0, 0, img.columns, t[1]]  # upper section of image
      # boundaries.coordinates[3] = [0, t[1], img.columns, img.rows - t[1]]  # lower section of image

    when :right_t   # only 3 zones expected, with horizontal division in right-side of vertical division
      t = Sqed::BoundaryFinder.color_boundary_finder(image: img, boundary_color: @boundary_color)  #defaults to detect vertical division, green line
      return if t.nil?

      left = [0, 0, t[0], img.rows]
      right = [t[2], 0, img.columns - t[2], img.rows]

      boundaries.set(0, left)            # left section of image

      # now subdivide right side
      irt = img.crop(*right, true)
      rt = Sqed::BoundaryFinder.color_boundary_finder(image: irt, scan: :columns, boundary_color: @boundary_color)  # set to detect horizontal division, (green line)
      return if rt.nil?
      boundaries.set(1, [t[2], 0, img.columns - t[2], rt[0]])                # upper section of image
      boundaries.set(2, [t[2], rt[2], img.columns - t[2], img.rows - rt[2]]) # lower section of image
      boundaries.complete = true
      # will return 1, 2, or 3

    when :offset_cross   # 4 zones expected, with horizontal division in right- and left- sides of vertical division
      t = Sqed::BoundaryFinder.color_boundary_finder(image: img, boundary_color: @boundary_color)  # defaults to detect vertical division, green line
      raise if t.nil?

      left = [0, 0, t[0], img.rows]                               # left section of image
      right = [t[2], 0, img.columns - t[2], img.rows]             # right section of image

      # now subdivide left side
      ilt = img.crop(*left, true)

      lt = Sqed::BoundaryFinder.color_boundary_finder(image: ilt, scan: :columns, boundary_color: @boundary_color)  # set to detect horizontal division, (green line)

      if !lt.nil?
        boundaries.set(0, [0, 0, left[2], lt[0]])                 # upper section of image
        boundaries.set(3, [0, lt[2], left[2], img.rows - lt[2]])  # lower section of image
      end

      # now subdivide right side
      irt = img.crop(*right, true)
      rt = Sqed::BoundaryFinder.color_boundary_finder(image: irt, scan: :columns, boundary_color: @boundary_color)  # set to detect horizontal division, (green line)
      return if rt.nil?

      boundaries.set(1, [t[2], 0, img.columns - t[2], rt[0]])                 # upper section of image
      boundaries.set(2, [t[2], rt[2], img.columns - t[2], img.rows - rt[2]])  # lower section of image
      # will return 1, 2, 3, or 4  //// does not handle staggered vertical boundary case
      
      boundaries.complete = true if boundaries.populated?

    else
      boundaries.set(0, [0, 0, img.columns, img.rows])   # totality of image as default
      # TODO: boundaries.complete status here?
      return    # return original image boundary if no method implemented
    end

  end


end
