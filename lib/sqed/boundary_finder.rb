require 'RMagick'

# Sqed Boundary Finders find boundaries on images and return co-ordinates of those boundaries.  They do not
# return derivative images. Finders operate on cropped images, i.e. only the "stage".
#
# This core of this code is from Emmanuel Oga's gist https://gist.github.com/EmmanuelOga/2476153.
#
class Sqed::BoundaryFinder

  # How small we accept a cropped picture to be. E.G. if it was 100x100 and
  # ratio 0.1, min output should be 10x10
  MIN_BOUNDARY_RATIO = 0.01    
 
  # How small we accept a cropped picture to be. E.G. if it was 100x100 and
  # ratio 0.1, min output should be 10x10
  MIN_CROP_RATIO = 0.1    # constant of this class

  # enumerate read-only parameters involved, accessible either as <varname> or @<varname>
  attr_reader :img, :x0, :y0, :x1, :y1, :min_width, :min_height, :rows, :columns
  
  # A Sqed::Boundaries instance, stores the coordinates of all fo the layout sections 
  attr_reader :boundaries

  # a symbol from SqedConfig::LAYOUTS
  attr_reader :layout

  # The proc containing the border finding algorithim
  attr_reader :is_border

  def initialize(image: image, is_border_proc: nil, min_ratio: MIN_CROP_RATIO, layout: layout, boundary_color: :green) # img must bef supplied, others overridable
    @layout = layout

    raise 'No image provided.' if image.nil? || image.class != Magick::Image

    # Initial co-ordinates
    @img, @min_ratio = image, min_ratio
    @x0, @y0 = 0, 0
    @x1, @y1 = img.columns, img.rows 
    @min_width, @min_height = img.columns * @min_ratio, img.rows * @min_ratio # minimum resultant area
    @columns, @rows = img.columns, img.rows

    # We need a border finder proc. Provide one if none was given.
    @is_border = is_border_proc || self.class.default_border_finder(img)  # if no proc specified, use default below

    true

    # !! Each subclass should run find 
  end
  
  # actually  + 1 (starting at zero?)
  def width   
    @x1 - @x0  
  end
 
  # actually  + 1 (starting at zero?)
  def height
    @y1 - @y0 
  end

  # Returns a Sqed::Boundaries instance
  # defined in subclasses
  def boundaries
    @boundaries ||= Sqed::Boundaries.new()
  end

  # Returns a Proc that, given a set of pixels (an edge of the image) decides
  # whether that edge is a border or not.
  def self.default_border_finder(img, samples = 5, threshold = 0.75, fuzz = 0.20)   # initially 0.95, 0.05
    # appears to assume sharp transition will occur in 5 pixels x/y
    # how is threshold defined?
    # works for 0.5, >0.137; 0.60, >0.14 0.65, >0.146; 0.70, >0.1875; 0.75, >0.1875; 0.8, >0.237; 0.85, >0.24; 0.90, >0.28; 0.95, >0.25
    # fails for 0.75, (0.18, 0.17,0.16,0.15); 0.70, 0.18;
    fuzz = (2**16 * fuzz).to_i  #same fuzz? not really, according to object_id

    # Returns true if the edge is a border. (?)
    lambda do |edge|
      border, non_border = 0.0, 0.0

      pixels = (0...samples).map { |n| edge[n * edge.length / samples] }
      pixels.combination(2).each { |a, b| a.fcmp(b, fuzz) ? border += 1 : non_border += 1 }

      border.to_f / (border + non_border) > threshold
    end
  end

  # Demo code for simple green line finding
  # Returns: the column (x position) in the middle of the single green vertical line dividing the stage
  #
  #  image: the image to sample
  #  sample_subdivision_size: an Integer, the distance in pixels b/w samples
  #  sample_cuttoff_factor: divides the total samples to determine the cutoff for counts that represent a border "hit"
  #     - for example, if you have an image of height 100 pixels, then a border is predicted when 5 or more green pixels are found for a given position
  #  scan (:rows|:columns), :rows finds vertical borders, :columns finds horizontal borders
  #
  def self.color_boundary_finder(image: image, sample_subdivision_size: 10, sample_cutoff_factor: 2, scan: :rows, boundary_color: :green)
    border_hits = {}
    samples_to_take = (image.send(scan) / sample_subdivision_size).to_i - 1

    (0..samples_to_take).each do |s|
      # Create a sample image a single pixel tall
      if scan == :rows
        j = image.crop(0, s * sample_subdivision_size, image.columns, 1)
      elsif scan == :columns
        j = image.crop(s * sample_subdivision_size, 0, 1, image.rows)
      else
        raise
      end

      # loop through every pixel in the image
      j.each_pixel do |pixel, c, r|
        index = ( (scan == :rows) ? c : r)

        # Our hit metric is dirt simple, if there is more of the boundary_color than the others, count + 1 for that column 
        if send("is_#{boundary_color}?", pixel) 
          # we have already hit that column previously, increment
          if border_hits[index]
            border_hits[index] += 1
          # initialize the newly hit column 1 
          else
            border_hits[index] = 1
          end
        end
      end
    end
    frequency_stats(border_hits, (samples_to_take / sample_cutoff_factor))
  end

  def self.is_green?(pixel)
   (pixel.green > pixel.red) && (pixel.green > pixel.blue)
  end

  def self.is_blue?(pixel)
   (pixel.blue > pixel.red) && (pixel.blue > pixel.green)
  end

  def self.is_red?(pixel)
   (pixel.red > pixel.blue) && (pixel.red > pixel.green)
  end

  # Takes a frequency hash of position => count key/values and returns
  # the median position of all positions that have a count greater than the cutoff

  def self.frequency_stats(frequency_hash, sample_cutoff = 0)
    return nil if sample_cutoff < 1
    hit_ranges = [] 
    frequency_hash.each do |position, count|
      if count > sample_cutoff 
        hit_ranges.push(position)
      end
    end
    return nil if hit_ranges.size < 3
    # return the position exactly in the middle of the array
    # we have to sort because the keys (positions) we examined came unordered from a hash originally
    hit_ranges.sort!
    [hit_ranges.first, hit_ranges[(hit_ranges.length / 2).to_i], hit_ranges.last]
  end

  private

  def find_edges
    return unless is_border

    u = x1 - 1
    x0.upto(u)     { |x| width_croppable?  && is_border[vline(x)] ? @x0 = x + 1 : break }
    (u).downto(x0) { |x| width_croppable?  && is_border[vline(x)] ? @x1 = x - 1 : break }

    u = y1 - 1
    0.upto(u)      { |y| height_croppable? && is_border[hline y] ? @y0 = y + 1 : break }
    (u).downto(y0) { |y| height_croppable? && is_border[hline y] ? @y1 = y - 1 : break }
    u = 0
  end

  def vline(x)
    img.get_pixels x, y0, 1, height - 1
  end

  def hline(y)
    img.get_pixels x0, y, width - 1, 1
  end

  def width_croppable?
    width > min_width
  end

  def height_croppable?
    height > min_height
  end
end
