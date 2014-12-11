require 'RMagick'

# This was "green" line finder attempting to be agnostic; now it is reworked to be color-specific line finder
#
class Sqed::BoundaryFinder::ColorLineFinder < Sqed::BoundaryFinder

  def initialize(image: image, is_border_proc: nil, min_ratio: MIN_BOUNDARY_RATIO, layout: layout, boundary_color: :green)
    super
    @boundary_color = boundary_color
    find_bands
  end

  private

  def find_bands
    case @layout    # boundaries.coordinates are referenced from stage image

    when :vertical_split    # can vertical and horizontal split be re-used to do cross cases?
      t = Sqed::BoundaryFinder.color_boundary_finder(image: img)  #detect vertical division, green line
      return if t.nil?
      boundaries.coordinates[0] = [0, 0, t[0], img.rows]  # left section of image
      boundaries.coordinates[1] = [t[2], 0, img.columns - t[2], img.rows]  # right section of image

    when :horizontal_split
      t = Sqed::BoundaryFinder.color_boundary_finder(image: img, scan: :columns, boundary_color: @boundary_color)  # set to detect horizontal division, (green line)
      return if t.nil?
      boundaries.coordinates[0] = [0, 0, img.columns, t[0]]  # upper section of image
      boundaries.coordinates[1] = [0, t[2], img.columns, img.rows - t[2]]  # lower section of image
      # boundaries.coordinates[2] = [0, 0, img.columns, t[1]]  # upper section of image
      # boundaries.coordinates[3] = [0, t[1], img.columns, img.rows - t[1]]  # lower section of image

    when :right_t   # only 3 zones expected, with horizontal division in right-side of vertical division
      t = Sqed::BoundaryFinder.color_boundary_finder(image: img)  #defaults to detect vertical division, green line
      return if t.nil?
      boundaries.coordinates[0] = [0, 0, t[0], img.rows]  # left section of image
      boundaries.coordinates[1] = [t[2], 0, img.columns - t[2], img.rows]  # left section of image

      # now subdivide right side
      irt = img.crop(*boundaries.coordinates[1], true)
      rt = Sqed::BoundaryFinder.color_boundary_finder(image: irt, scan: :columns)  # set to detect horizontal division, (green line)
      return if rt.nil?
      boundaries.coordinates[1] = [t[2], 0, img.columns - t[2], rt[0]]  # upper section of image
      boundaries.coordinates[2] = [t[2], rt[2], img.columns - t[2], img.rows - rt[2]]  # lower section of image
      # will return 1, 2, or 3

    when :offset_cross   # 4 zones expected, with horizontal division in right- and left- sides of vertical division
      t = Sqed::BoundaryFinder.color_boundary_finder(image: img)  # defaults to detect vertical division, green line
      raise if t.nil?
      boundaries.coordinates[0] = [0, 0, t[0], img.rows]  # left section of image
      boundaries.coordinates[1] = [t[2], 0, img.columns - t[2], img.rows]  # right section of image

      # now subdivide left side
      ilt = img.crop(*boundaries.coordinates[0], true)

      lt = Sqed::BoundaryFinder.color_boundary_finder(image: ilt, scan: :columns)  # set to detect horizontal division, (green line)
      if !lt.nil?
        boundaries.coordinates[0] = [0, 0, t[0], lt[0]]  # upper section of image
        boundaries.coordinates[3] = [0, lt[2], t[0], img.rows - lt[2]]  # lower section of image
      end

      # now subdivide right side
      irt = img.crop(*boundaries.coordinates[1], true)
      rt = Sqed::BoundaryFinder.color_boundary_finder(image: irt, scan: :columns)  # set to detect horizontal division, (green line)
      return if rt.nil?

      boundaries.coordinates[1] = [t[2], 0, img.columns - t[2], rt[0]]  # upper section of image
      boundaries.coordinates[2] = [t[2], rt[2], img.columns - t[2], img.rows - rt[2]]  # lower section of image
      # will return 1, 2, 3, or 4  //// does not handle staggered vertical boundary case

    else
      boundaries.coordinates[0] = [0, 0, img.columns, img.rows]  # totality of image as default
      return    # return original image boundary if no method implemented
    end

  end


end
