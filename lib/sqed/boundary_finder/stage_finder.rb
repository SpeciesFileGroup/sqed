require 'RMagick'

# Some of this code was originally inspired by Emmanuel Oga's gist https://gist.github.com/EmmanuelOga/2476153.
#
class Sqed::BoundaryFinder::StageFinder < Sqed::BoundaryFinder
  
  # The proc containing the border finding algorithim
  attr_reader :is_border

  # assume white-ish image on dark-ish background

  # How small we accept a cropped picture to be. E.G. if it was 100x100 and
  # ratio 0.1, min output should be 10x10
  MIN_CROP_RATIO = 0.1    

  attr_reader :x0, :y0, :x1, :y1, :min_width, :min_height, :rows, :columns 

  def initialize(image: image, is_border_proc: nil, min_ratio: MIN_CROP_RATIO)
    super(image: image, layout: :internal_box)

    @min_ratio =  min_ratio

    # Initial co-ordinates
    @x0, @y0 = 0, 0
    @x1, @y1 = img.columns, img.rows 
    @min_width, @min_height = img.columns * @min_ratio, img.rows * @min_ratio # minimum resultant area
    @columns, @rows = img.columns, img.rows

    # We need a border finder proc. Provide one if none was given.
    @is_border = is_border_proc || self.class.default_border_finder(img)  # if no proc specified, use default below

    @x00 = @x0
    @y00 = @y0
    @height0 = height
    @width0 = width
    find_edges
  end

  private

  # Returns a Proc that, given a set of pixels (an edge of the image) decides
  # whether that edge is a border or not.
  # 
  # (img, samples = 5, threshold = 0.95, fuzz_factor = 0.5)  # initially 
  # (img, samples = 50, threshold = 0.9, fuzz_factor = 0.1)   # semi-working on synthetic images 08-dec-2014 (x)
  # (img, samples = 20, threshold = 0.8, fuzz_factor = 0.2)   # WORKS with synthetic images and changes to x0, y0, width, height
  # 
  # appears to assume sharp transition will occur in 5 pixels x/y
  #
  # how is threshold defined?
  # works for 0.5, >0.137; 0.60, >0.14 0.65, >0.146; 0.70, >0.1875; 0.75, >0.1875; 0.8, >0.237; 0.85, >0.24; 0.90, >0.28; 0.95, >0.25
  # fails for 0.75, (0.18, 0.17,0.16,0.15); 0.70, 0.18;
  #
  def self.default_border_finder(img, samples = 5, threshold = 0.75, fuzz_factor = 0.40)   # working on non-synthetic images 04-dec-2014
   fuzz = ((Magick::QuantumRange + 1)  * fuzz_factor).to_i  
    # Returns true if the edge is a border (border meaning outer region to be cropped)
    lambda do |edge|
      border, non_border = 0.0, 0.0 # maybe should be called outer, inner

      pixels = (0...samples).map { |n| edge[n * edge.length / samples] }
      pixels.combination(2).each do |a, b|
        if a.fcmp(b, fuzz) then
          border += 1
        else
          non_border += 1
        end
      end
      bratio = border.to_f / (border + non_border)
      if bratio > threshold
        return true
      else
        return false
      end
      border.to_f / (border + non_border) > threshold # number of matching string of pixels/(2 x total pixels - a.k.a. samples?)
    end
  end

  def find_edges
    # handle this exception
    return unless is_border # return if no process defined or set for @is_border

    u = x1 - 1    # rightmost pixel (kind of)
    # increment from left to right
    x0.upto(u) do |x|
      if width_croppable? && is_border[vline(x)] then
        @x0 = x + 1
      else
        break
      end
    end
    # increment from left to right
    (u).downto(x0) { |x| width_croppable?  && is_border[vline(x)] ? @x1 = x - 1 : break }

    u = y1 - 1
    0.upto(u) do |y|
      if height_croppable? && is_border[hline y] then
        @y0 = y + 1
      else
        break
      end
    end
    (u).downto(y0) { |y| height_croppable? && is_border[hline y] ? @y1 = y - 1 : break }
    u = 0

    delta_x = 0 #width/50    # 2% of cropped image to make up for trapezoidal distortion
    delta_y = 0 #height/50   # 2% of cropped image to make up for trapezoidal distortion <- NOT 3%
  
    # TODO: add conditions
    boundaries.complete = true 
    boundaries.coordinates[0] = [x0 + delta_x, y0 + delta_y, width - 2*delta_x, height - 2*delta_y]
  end

  def width_croppable?
    width > min_width
  end

  def height_croppable?
    height > min_height
  end

  def vline(x)
    img.get_pixels x, @y00, 1, @height0 - 1
  end

  def hline(y)
    img.get_pixels @x00, y, @width0 - 1, 1
  end

  # actually  + 1 (starting at zero?)
  def width   
    @x1 - @x0  
  end
 
  # actually  + 1 (starting at zero?)
  def height
    @y1 - @y0 
  end

end
