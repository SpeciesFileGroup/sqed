# Sqed Boundary Finders find boundaries on images and return co-ordinates of those boundaries.  They do not
# return derivative images. Finders operate on cropped images, i.e. only the "stage".
#
class Sqed::BoundaryFinder

  THUMB_SIZE = 100 
  COLOR_DELTA = 1.3 # color (e.g. red) must be this much be *COLOR_DELTA > than other values (e.g. blue/green) 

  # the passed image
  attr_reader :img

  # a symbol from SqedConfig::LAYOUTS
  attr_reader :layout

  # A Sqed::Boundaries instance, stores the coordinates of all of the layout sections 
  attr_reader :boundaries

  # Whether to compress the original image to a thumbnail when finding boundaries
  attr_reader :use_thumbnail

  # when we compute using a derived thumbnail we temporarily store the full size image here
  attr_reader :original_image

  def initialize(image: image, layout: layout, use_thumbnail: true)
    raise 'No layout provided.' if layout.nil?
    raise 'No image provided.' if image.nil? || image.class.name != 'Magick::Image'

    @use_thumbnail = use_thumbnail

    @layout = layout
    @img = image
    true
  end

  # Returns a Sqed::Boundaries instance initialized to the number of sections in the passed layout.
  def boundaries
    @boundaries ||= Sqed::Boundaries.new(@layout)
  end

  def longest_thumbnail_axis
    img.columns > img.rows ? :width : :height 
  end

  def thumbnail_height
    if longest_thumbnail_axis == :height
      THUMB_SIZE
    else
      (img.rows.to_f * (THUMB_SIZE.to_f / img.columns.to_f)).round.to_i
    end
  end

  def thumbnail_width
    if longest_thumbnail_axis == :width
      THUMB_SIZE
    else
      (img.columns.to_f * (THUMB_SIZE.to_f / img.rows.to_f)).round.to_i
    end
  end

  # see https://rmagick.github.io/image3.html#thumbnail
  def thumbnail
    img.thumbnail(thumbnail_width, thumbnail_height)
  end

  def width_factor
    img.columns.to_f / thumbnail_width.to_f
  end

  def height_factor
    img.rows.to_f / thumbnail_height.to_f
  end

  def zoom_boundaries
    boundaries.zoom(width_factor, height_factor )
  end

  # return [Integer, nil]
  #   sample more with small images, less with large images
  #   we want to return larger numbers (= faster sampling)
  def self.get_subdivision_size(image_width)
    case image_width
    when nil
     nil 
    when 0..140
       6
    when 141..640
       12
    when 641..1000
      16
    when 1001..3000
      60 
    when 3001..6400
      80 
    else
      140 
    end
  end

  # @return [Array]
  #   the x or y position returned as a start, mid, and end coordinate that represent the width  of the colored line that completely divides the image, e.g. [9, 15, 16] 
  #
  # @param image
  #   the image to sample
  #
  # @param sample_subdivision_size
  #   an Integer, the distance in pixels b/w samples
  #
  # @param sample_cutoff_factor: (0.0-1.0)
  #   if provided over-rides the default cutoff calculation by reducing the number of pixels required to be considered a border hit
  #     - for example, if you have an image of height 100 pixels, and a sample_subdivision_size of 10, and a sample_cutoff_factor of .8 
  #       then only posititions with 8 ((100/10)*.8) or more hits
  #     - when nil the cutoff defaults to the maximum of the pairwise difference between hit counts
  #
  # @param scan
  #   (:rows|:columns), :rows finds vertical borders, :columns finds horizontal borders
  #
  def self.color_boundary_finder(image: image, sample_subdivision_size: nil, sample_cutoff_factor: nil, scan: :rows, boundary_color: :green)

    image_width = image.send(scan)
    sample_subdivision_size = get_subdivision_size(image_width) if sample_subdivision_size.nil?
    samples_to_take = (image_width / sample_subdivision_size).to_i - 1

    border_hits = {}

    (0..samples_to_take).each do |s|
      # Create a sample image a single pixel tall
      if scan == :rows
        j = image.crop(0, s * sample_subdivision_size, image.columns, 1, true)
      elsif scan == :columns
        j = image.crop(s * sample_subdivision_size, 0, 1, image.rows, true)
      else
        raise
      end

      j.each_pixel do |pixel, c, r|
        index = ( (scan == :rows) ? c : r)

        # Our hit metric is dirt simple, if there is some percentage more of the boundary_color than the others, count + 1 for that column 
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

    return nil if border_hits.length < 2

    if sample_cutoff_factor.nil?
      cutoff = max_difference(border_hits.values)

      cutoff = border_hits.values.first - 1 if cutoff == 0 # difference of two identical things is 0
    else
      cutoff = (samples_to_take * sample_cutoff_factor).to_i
    end

    frequency_stats(border_hits, cutoff)
  end

  def self.is_green?(pixel)
    (pixel.green > pixel.red*COLOR_DELTA) && (pixel.green > pixel.blue*COLOR_DELTA)  
  end

  def self.is_blue?(pixel)
    (pixel.blue > pixel.red*COLOR_DELTA) && (pixel.blue > pixel.green*COLOR_DELTA)   
  end

  def self.is_red?(pixel)
    (pixel.red > pixel.blue*COLOR_DELTA) && (pixel.red > pixel.green*COLOR_DELTA)   
  end

  def self.is_black?(pixel)
    black_threshold = 65535*0.15    #tune for black
    (pixel.red < black_threshold) &&  (pixel.blue < black_threshold) &&  (pixel.green < black_threshold)
  end

  # return [Array]
  #   the start, mid, endpoint position of all (pixel) positions that have a count greater than the cutoff
  def self.frequency_stats(frequency_hash, sample_cutoff = 0)
   
    return nil if sample_cutoff.nil? ||  sample_cutoff < 1 
    hit_ranges = [] 

    frequency_hash.each do |position, count|
      if count >= sample_cutoff 
        hit_ranges.push(position)
      end
    end

    case hit_ranges.size
    when 1
      c = hit_ranges[0]
      hit_ranges = [c - 1, c, c + 1]
    when 2
      hit_ranges.sort!
      c1 = hit_ranges[0]
      c2 = hit_ranges[1]
      hit_ranges = [c1,  c2, c2 + (c2 - c1)]
    when 0 
      return nil 
    end

    # we have to sort because the keys (positions) we examined came unordered from a hash originally
    hit_ranges.sort!

    # return the position exactly in the middle of the array
    [hit_ranges.first, hit_ranges[(hit_ranges.length / 2).to_i], hit_ranges.last]
  end

  # @return [Array] 
  #  like [0,1,2]
  # If median-min or max-median * width_factor are different from one another (by more than width_factor) then replace the larger wth the median +/- 1/2 the smaller
  # Given [10, 12, 20] and width_factor 2 the result will be [10, 12, 13]  
  #
  def corrected_frequency(frequency_stats, width_factor = 3.0 )
    v0 = frequency_stats[0]
    m = frequency_stats[1]
    v2 = frequency_stats[2]

    a = m - v0 
    b = v2 - m 

    largest = (a > b ? a : b)

    if a * width_factor > largest
      [(m - (v2 - m)/2).to_i, m, v2]
    elsif b * width_factor > largest
      [ v0, m, (m + (m - v0)/2).to_i ]
    else
      frequency_stats
    end
  end



  # Returns an Integer, the maximum of the pairwise differences of the values in the array
  # For example, given
  #   [1,2,3,9,6,2,0]
  # The resulting pairwise array is
  #   [1,1,6,3,4,2]
  # The max (value returned) is
  #   6
  def self.max_pairwise_difference(array)
    (0..array.length-2).map{|i| (array[i] - array[i+1]).abs }.max
  end

  def self.max_difference(array)
    array.max - array.min
  end

  def self.derivative_signs(array)
    (0..array.length-2).map { |i| (array[i+1] - array[i]) <=> 0 }
  end

  def self.derivative(array)
    (0..array.length-2).map { |i| array[i+1] - array[i] }
  end

end

