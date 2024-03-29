class Sqed

  # Sqed Boundary Finders find boundaries on images and return co-ordinates of
  # those boundaries.  They do not  return derivative images.
  # Finders operate on cropped images, i.e. only the "stage".
  #
  class BoundaryFinder

    # Problemantic (e.g. seven slot) seem to resolve at ~360
    THUMB_SIZE = 100
    COLOR_DELTA = 1.3 # color (e.g. red) must be this much be *COLOR_DELTA > than other values (e.g. blue/green)

    # the passed image
    attr_reader :image

    # a symbol from SqedConfig::LAYOUTS
    attr_reader :layout

    # A Sqed::Boundaries instance, stores the coordinates of all of the layout sections
    attr_reader :boundaries

    # @return Boolean
    # Whether to compress the original image to a thumbnail when finding boundaries at certain steps of the processing
    attr_reader :use_thumbnail

    # when we compute using a derived thumbnail we temporarily store the full size image here
    attr_reader :original_image

    def initialize(**opts)
      # image: image, layout: layout, use_thumbnail: true
      @use_thumbnail = opts[:use_thumbnail]
      @use_thumbnail = true if @use_thumbnail.nil?
      @layout = opts[:layout]
      @image = opts[:image]

      raise Sqed::Error, 'No layout provided.' if layout.nil?
      raise Sqed::Error, 'No image provided.' if image.nil? || image.class.name != 'Magick::Image'

      true
    end

    # Returns a Sqed::Boundaries instance initialized to the number of sections in the passed layout.
    def boundaries
      @boundaries ||= Sqed::Boundaries.new(@layout)
    end

    def longest_thumbnail_axis
      image.columns > image.rows ? :width : :height
    end

    def thumbnail_height
      if longest_thumbnail_axis == :height
        THUMB_SIZE
      else
        (image.rows.to_f * (THUMB_SIZE.to_f / image.columns.to_f)).round.to_i
      end
    end

    def thumbnail_width
      if longest_thumbnail_axis == :width
        THUMB_SIZE
      else
        (image.columns.to_f * (THUMB_SIZE.to_f / image.rows.to_f)).round.to_i
      end
    end

    # see https://rmagick.github.io/image3.html#thumbnail
    def thumbnail
      image.thumbnail(thumbnail_width, thumbnail_height)
    end

    def width_factor
      image.columns.to_f / thumbnail_width.to_f
    end

    def height_factor
      image.rows.to_f / thumbnail_height.to_f
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
    #
    # image: image, sample_subdivision_size: nil, sample_cutoff_factor: nil, scan: :rows, boundary_color: :green)
    def self.color_boundary_finder(**opts)
      image = opts[:image]
      sample_subdivision_size = opts[:sample_subdivision_size]
      sample_cutoff_factor = opts[:sample_cutoff_factor]
      scan = opts[:scan] || :rows
      boundary_color = opts[:boundary_color] || :green

      image_width = image.send(scan)
      sample_subdivision_size = get_subdivision_size(image_width) if sample_subdivision_size.nil?

      attempts = 0
      while attempts < 5 do
        samples_to_take = (image_width / sample_subdivision_size).to_i - 1
        border_hits = sample_border(image, boundary_color, samples_to_take, sample_subdivision_size, scan)

        break if border_hits.select{|k,v| v > 1}.size > 2 || sample_subdivision_size == 1

        sample_subdivision_size = (sample_subdivision_size.to_f / 2.0).to_i
        attempts += 1
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

    def self.sample_border(image, boundary_color, samples_to_take, sample_subdivision_size, scan)
      border_hits = {}

      (0..samples_to_take).each do |s|
        # Create a sample image a single pixel tall
        if scan == :rows
          j = image.crop(0, s * sample_subdivision_size, image.columns, 1, true)
        elsif scan == :columns
          j = image.crop(s * sample_subdivision_size, 0, 1, image.rows, true)
        else
          raise Sqed::Error
        end

        j.each_pixel do |pixel, c, r|
          index = (scan == :rows) ? c : r

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

      border_hits
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
      black_threshold = 65535 * 0.15 #tune for black
      (pixel.red < black_threshold) &&  (pixel.blue < black_threshold) &&  (pixel.green < black_threshold)
    end

    # return [Array]
    #   the start, mid, endpoint position of all (pixel) positions that have a count greater than the cutoff
    def self.frequency_stats(frequency_hash, sample_cutoff = 0)

      return nil if sample_cutoff.nil? || sample_cutoff < 1
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
        hit_ranges = [c1, c2, c2 + (c2 - c1)]
      when 0
        return nil
      end

      # we have to sort because the keys (positions) we examined came unordered from a hash originally
      hit_ranges.sort!

      # return the position exactly in the middle of the array
      [hit_ranges.first, hit_ranges[(hit_ranges.length / 2).to_i], hit_ranges.last]
    end

    def self.max_difference(array)
      array.max - array.min
    end

    # Usused

    # Returns an Integer, the maximum of the pairwise differences of the values in the array
    # For example, given
    #   [1,2,3,9,6,2,0]
    # The resulting pairwise array is
    #   [1,1,6,3,4,2]
    # The max (value returned) is
    #   6
    def self.max_pairwise_difference(array)
      (0..array.length - 2).map{|i| (array[i] - array[i + 1]).abs }.max
    end

    def self.derivative_signs(array)
      (0..array.length - 2).map { |i| (array[i + 1] - array[i]) <=> 0 }
    end

    def self.derivative(array)
      (0..array.length - 2).map { |i| array[i + 1] - array[i] }
    end

  end
end
