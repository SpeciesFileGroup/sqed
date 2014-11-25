require 'RMagick'

# This was "green" line finder attempting to be agnostic; now it is reworked to be color-specific line finder
#
class Sqed::BoundaryFinder::AgnosticLineFinder < Sqed::BoundaryFinder

  attr_reader :is_band

  def initialize(image: image, is_border_proc: nil, min_ratio: MIN_BOUNDARY_RATIO, layout: layout, boundary_color: :green)
    super

    @is_band = is_border_proc || self.class.default_line_finder(img)  # if no proc specified, use default below

    find_bands
    # output
  end

  def output
    # @img = @img.crop(x0, y0, width, height, true)
  end

  # Returns a Proc that, given a set of pixels (an edge of the image) decides
  # whether that edge is a band or not.
  # def self.default_border_finder(img, samples = 5, threshold = 0.75, fuzz = 0.20)   # initially 0.95, 0.05
  def self.default_line_finder(img, samples = 5, threshold = 0.85, fuzz_factor = 0.20)   # canonically 0.75, 0.10
    fuzz = (2**QuantumDepth * fuzz_factor).to_i  #same fuzz? not really, according to object_id
    # first priority is get vertical line: done ??
    lambda do |edge|
    end
  end

  private

  def find_bands
    return unless is_band

    case @layout    # boundaries.coordinates are referenced from stage image
      when :right_t   # only 3 zones expected, with horizontal division in right-side of vertical division
        t = Sqed::BoundaryFinder.color_boundary_finder(image: img)  #defaults to detect vertical division, green line
        raise if t.nil?
        boundaries.coordinates[0] = [0, 0, t[0], img.rows]  # left section of image
        boundaries.coordinates[1] = [t[2], 0, img.columns - t[2], img.rows]  # left section of image

        # now subdivide right side
        irt = img.crop(*boundaries.coordinates[1], true)
        rt = Sqed::BoundaryFinder.color_boundary_finder(image: irt, scan: :columns)  # set to detect horizontal division, (green line)
        return if rt.nil?
        boundaries.coordinates[1] = [t[2], 0, img.columns - t[2], rt[0]]  # upper section of image
        boundaries.coordinates[2] = [t[2], rt[2], img.columns - t[2], img.rows - rt[2]]  # lower section of image

      when :offset_cross   # 4 zones expected, with horizontal division in right- and left- sides of vertical division
        t = Sqed::BoundaryFinder.color_boundary_finder(image: img)  #defaults to detect vertical division, green line
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

         u = 0
      when :foo
      else
        boundaries.coordinates[0] = [corners[0][0][0], corners[0][0][1], corners[0][1][0], corners[0][1][1]]
        boundaries.coordinates[1] = [corners[2][0][0], corners[2][0][1], corners[2][1][0] - corners[2][0][0], corners[2][1][1] - corners[2][0][1]]
        boundaries.coordinates[2] = [corners[3][0][0], corners[3][0][1], corners[3][1][0] - corners[3][0][0], corners[3][1][1] - corners[3][0][1]]
        boundaries.coordinates[3] = [corners[1][0][0], corners[1][0][1], corners[1][1][0] - corners[1][0][0], corners[1][1][1] - corners[1][0][1]]
    end


    # (0..3).each do |i|    #this produces spurious results ! !
    #   area = img.crop(*boundaries.for(i),true)
    #   area.write("area#{i}.jpg")
    # end
    u = 0
  end


end
