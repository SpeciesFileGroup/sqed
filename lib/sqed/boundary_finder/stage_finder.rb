require 'RMagick'

# Some of this code was originally inspired by Emmanuel Oga's gist https://gist.github.com/EmmanuelOga/2476153.
#
class Sqed::BoundaryFinder::StageFinder < Sqed::BoundaryFinder

  # How small we accept a cropped picture to be. E.G. if it was 100x100 and
  # ratio 0.1, min output should be 10x10
  MIN_CROP_RATIO = 0.1   
  
  # The proc containing the border finding algorithim
  attr_reader :is_border

  # assume white-ish image on dark-ish background

  def initialize(image: image, is_border_proc: nil, min_ratio: MIN_CROP_RATIO, layout: layout, boundary_color: :green)
    @layout = :internal_box
    super

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
    xxx = 0
    # output
  end

  # actually  + 1 (starting at zero?)
  def width   
    @x1 - @x0  
  end
 
  # actually  + 1 (starting at zero?)
  def height
    @y1 - @y0 
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

  def output
    delta_x = width/33    # 3% of cropped image to make up for trapezoidal distortion
    delta_y = height/33    # 3% of cropped image to make up for trapezoidal distortion <- NOT 3%
    @img = @img.crop(x0 + delta_x, y0 + delta_y, width - 2*delta_x, height - 2*delta_y, true)
    # 2*delta_s for 3rd and 4th args
    # @img.write('cropped.jpg')
  end

  # Returns a Proc that, given a set of pixels (an edge of the image) decides
  # whether that edge is a border or not.
  # **************************
  # def self.default_border_finder(img, samples = 5, threshold = 0.75, fuzz = 0.20)   # initially 0.95, 0.05
  def self.default_border_finder(img, samples = 5, threshold = 0.75, fuzz_factor = 0.40)   # working on non-synthetic images 04-dec-2014
  # def self.default_border_finder(img, samples = 50, threshold = 0.9, fuzz_factor = 0.1)   # semi-working on synthetic images 08-dec-2014 (x)
  #   def self.default_border_finder(img, samples = 20, threshold = 0.8, fuzz_factor = 0.2)   # WORKS with synthetic images and changes to x0, y0, width, height
    # def self.default_border_finder(img, samples = 5, threshold = 0.75, fuzz_factor = 0.20)   # initially 0.95, 0.05
    # appears to assume sharp transition will occur in 5 pixels x/y
    # how is threshold defined?
    # works for 0.5, >0.137; 0.60, >0.14 0.65, >0.146; 0.70, >0.1875; 0.75, >0.1875; 0.8, >0.237; 0.85, >0.24; 0.90, >0.28; 0.95, >0.25
    # fails for 0.75, (0.18, 0.17,0.16,0.15); 0.70, 0.18;
    # fuzz = (2**16 * fuzz_factor).to_i  #same fuzz? not really, according to object_id
    fuzz = ((::QuantumRange + 1)  * fuzz_factor).to_i  # could use QuantumRange instead of 2**Qu..

    # Returns true if the edge is a border. (?) (border meaning outer region to be cropped)
    lambda do |edge|
      border, non_border = 0.0, 0.0 #maybe should be called outer, inner

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

  def vline(x)
    img.get_pixels x, @y00, 1, @height0 - 1
  end

  def hline(y)
    img.get_pixels @x00, y, @width0 - 1, 1
  end

  private

  # TODO: If this is the same as superclass remove.
  def find_edges
    # handle this exception
    return unless is_border #return if no process defined or set for @is_border

    u = x1 - 1    #rightmost pixel (kind of)
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

# Superclass version
# def find_edges
#     return unless is_border

#     u = x1 - 1
#     x0.upto(u)     { |x| width_croppable?  && is_border[vline(x)] ? @x0 = x + 1 : break }
#     (u).downto(x0) { |x| width_croppable?  && is_border[vline(x)] ? @x1 = x - 1 : break }

#     u = y1 - 1
#     0.upto(u)      { |y| height_croppable? && is_border[hline y] ? @y0 = y + 1 : break }
#     (u).downto(y0) { |y| height_croppable? && is_border[hline y] ? @y1 = y - 1 : break }
#     u = 0
#   end

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
