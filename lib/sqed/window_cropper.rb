require 'RMagick'

# a = Sqed::WindowCropper.new(image: InMemoryImage, method: :default)
# a.result # -> image in memory

class Sqed
  class WindowCropper

    attr_accessor :stage_locator, :initial_image, :cropped_image, 
      :x_offset, :y_offset, :width, :height

    CROP_METHODS = [:default]

    # image = ImageList.new('white_black.jpg')
    def initialize(image: image, stage_locator: :default)
      @initial_image = image #  Magick::Image.read('testImage.JPG.jpeg').first
      @cropped_image = nil
      @stage_locator = stage_locator
     #WindowCropper.crop(@x_offset, @y_offset, @width, @height)
    end

    def method=(value)
      raise if  !CROP_METHODS.include?(value)
      @stage_locator = value 
    end

    def crop
      stage_locate if @width.nil? # check one of the values, if not set then locate before cropping
      @cropped_image = @initial_image.crop(@x_offset, @y_offset, @width, @height)
    end

    def stage_locate
      send(@stage_locator)
    end

    # The default stage locator boundries method, returns the whole image with nothing cropped right now.
    # TODO: @jrflood, make this actually crop something, the image is in @intial_image, you need not hard code anything, just run the specs.
    def default
      @x_offset = 0
      @y_offset = 0
      @width = @initial_image.columns
      @height = @initial_image.rows
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
      crop if @cropped_image.nil?
      @cropped_image
    end

  end
end
