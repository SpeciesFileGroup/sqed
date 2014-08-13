include Magick


# a = Sqed::WindowCropper.new(image: InMemoryImage, method: :default)
# a.result # -> image in memory



class Sqed::WindowCropper

  attr_accessor :stage_locator, :initial_image, :cropped_image, 
    :x_offset, :y_offset, :width, :height

  CROP_METHODS = [:default]

  # image = ImageList.new('white_black.jpg')
  def initialize(image: image, stage_locator: :default)
    @initial_image = image
    @cropped_image = nil
    @stage_locator = stage_locator 
    @x_offset = 0
    @y_offset = 0
    @width = 100 # just to make things work
    @height = 100 # just to make things work
  end
 
  def method=(value)
    raise if  !CROP_METHODS.include?(value)
    @stage_locator = value 
  end

  def crop
    some_result = @initial_image.crop(@x_offset, @y_offset, @width, @height)
    @cropped_image = some_result 
    true
  end

  def stage_locate
    send(@stage_locator)
  end

  # The default stage locator boundries method 
  def default
    # Do detection stuff, set temp variables.
    # MAYBE!! #https://gist.github.com/EmmanuelOga/2476153 (does't work ?!)
    @x_offset = x_off 
    @y_offset = y_off 
    @width = w 
    @height = h 
  end

  # Another potential @stage_locator method (:fiji_process)
  #def fiji_process
  #  # do cropping stuff in fiji, put in some_result
  #  # drop to a shell
  #  #   `    ` 
  #  @cropped_image = some_result 
  #end

  # Another potential @stage_locator method? Or maybe an alternate crop method
  def by_shave
    # use -shave option with crop to just trim down the image 
  end

  def result
    @cropped_imge
  end

end
