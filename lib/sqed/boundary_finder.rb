require 'rmagick'

# Sqed Boundary Finders find boundaries on images and return co-ordinates of those boundaries.  They do not
# return derivative images. Finders operate on cropped images, i.e. only the "stage".
#
class Sqed::BoundaryFinder
  # the passed image
  attr_reader :img

  # a symbol from SqedConfig::LAYOUTS
  attr_reader :layout

  # A Sqed::Boundaries instance, stores the coordinates of all of the layout sections 
  attr_reader :boundaries

  def initialize(image: image, layout: layout)
    raise 'No layout provided.' if layout.nil?
    raise 'No image provided.' if image.nil? || image.class != Magick::Image

    @layout = layout
    @img = image
    true
  end

  # Returns a Sqed::Boundaries instance initialized to the number of sections in the passed layout.
  def boundaries
    @boundaries ||= Sqed::Boundaries.new(@layout)
  end

  # @return
  #   the column (x position) in the middle of the single green vertical line dividing the stage
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
  def self.color_boundary_finder(image: image, sample_subdivision_size: 10, sample_cutoff_factor: nil, scan: :rows, boundary_color: :green) 
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
    else
      cutoff = (samples_to_take * sample_cutoff_factor).to_i
    end

    frequency_stats(border_hits, cutoff)
  end

  def self.is_green?(pixel)
    (pixel.green > pixel.red*1.2) && (pixel.green > pixel.blue*1.2)  
  end

  def self.is_blue?(pixel)
    (pixel.blue > pixel.red*1.2) && (pixel.blue > pixel.green*1.2)   
  end

  def self.is_red?(pixel)
    (pixel.red > pixel.blue*1.2) && (pixel.red > pixel.green*1.2)   
  end

  def self.is_black?(pixel)
    black_threshold = 65535*0.15    #tune for black
    (pixel.red < black_threshold) &&  (pixel.blue < black_threshold) &&  (pixel.green < black_threshold)
  end

  # Takes a frequency hash of position => count key/values and returns
  # the median position of all positions that have a count greater than the cutoff
  def self.frequency_stats(frequency_hash, sample_cutoff = 0)
    return nil if sample_cutoff.nil? ||  sample_cutoff < 1 
    hit_ranges = [] 

    frequency_hash.each do |position, count|
      if count >= sample_cutoff 
        hit_ranges.push(position)
      end
    end

    return nil if hit_ranges.size < 3

    # we have to sort because the keys (positions) we examined came unordered from a hash originally
    hit_ranges.sort!

    # return the position exactly in the middle of the array
    [hit_ranges.first, hit_ranges[(hit_ranges.length / 2).to_i], hit_ranges.last]
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
