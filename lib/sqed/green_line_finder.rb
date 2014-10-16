require 'RMagick'

# Auto crop an image by detecting solid edges around them.  Adapted from Emmanuel Oga/autocrop.rb

class Sqed::GreenLineFinder

  # How small we accept a cropped picture to be. E.G. if it was 100x100 and
  # ratio 0.1, min output should be 10x10
  MIN_CROP_RATIO = 0.1    # constant of this class
  # enumerate read-only parameters involved, accessible either as  <varname> or @<varname>
  attr_reader :img, :x0, :y0, :x1, :y1, :min_width, :min_height, :rows, :columns, :is_border

  # assume white-ish image on dark-ish background

  def initialize(img, is_border_proc = nil, min_ratio = MIN_CROP_RATIO) # img must be supplied, others overridable
    @img, @min_ratio = img, min_ratio

    # Coordinates
    @x0, @y0 = 0, 0; @x1, @y1 = img.columns, img.rows # total image area
    @min_width, @min_height = img.columns * @min_ratio, img.rows * @min_ratio # minimum resultant area
    @columns, @rows = img.columns, img.rows
    # We need a band finder proc. Provide one if none was given.
    # @green_pixel = Pixel.new(13000,30000,5000)
    green_pixel = img.pixel_color(2514,1319)
    # @target = Image.new( 20, @columns/1000) { self.background_color = green_pixel }
    @target = Image.new(20, 5)
    t = img.export_pixels(2500, 1300, 20, 5)
    @target = @target.import_pixels(0,0,20,5,'RGB',t)
    # @target = @target.gaussian_blur(0.0, 3.0)
    # @target.fuzz = 0.09
    # img.fuzz = 0.09
    @target.write('fool.jpg')
    r = img.find_similar_region(@target,0,0)
    #so, it can find this EXACT region, but not one right next door!
    @is_border = is_border_proc || self.class.default_border_finder(img)  # if no proc specified, use default below

    find_edges
    output
  end

  def width   #
    @x1 - @x0   # actually + 1
  end

  def height
    @y1 - @y0  # actually  + 1
  end

  def output
    @img = @img.crop(x0, y0, width, height, true)
  end

  # Returns a Proc that, given a set of pixels (an edge of the image) decides
  # whether that edge is a band or not.
  def self.default_border_finder(img, samples = 5, threshold = 0.75, fuzz = 0.20)   # initially 0.95, 0.05
    # appears to assume sharp transition will occur in 5 pixels x/y
    # how is threshold defined?
    # works for 0.5, >0.137; 0.60, >0.14 0.65, >0.146; 0.70, >0.1875; 0.75, >0.1875; 0.8, >0.237; 0.85, >0.24; 0.90, >0.28; 0.95, >0.25
    # fails for 0.75, (0.18, 0.17,0.16,0.15); 0.70, 0.18;
    fuzz = (2**16 * fuzz).to_i  #same fuzz? not really, according to object_id
    # r = img.find_similar_region(@target, 0,0)
        # Returns true if the edge is a band. (?)
    # want to return true if find a green line
    # first priority is get vertical line
    lambda do |edge|
      band, non_border = 0.0, 0.0

      pixels = (0...samples).map { |n| edge[n * edge.length / samples] }
      # want ~1% of pixels to be like the model green red<13000, green>30000, blue<5000
      pixels.combination(2).each { |a, b| a.fcmp(b, fuzz) ? band += 1 : non_border += 1 }
      # pixels.combination(5).each { |a| a.fcmp(@green_pixel, fuzz) ? band += 1 : non_border += 1 }

      band.to_f / (band + non_border) > threshold
    end
  end

  private

  def find_edges
    return unless is_border

    u = x1 - 1
    x0.upto(u) do |x|
      if width_croppable? && is_border[vline(x)] then
        @x0 = x + 1
      else
        break
      end
    end
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