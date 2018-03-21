require 'rmagick'

# An agnostic pattern finder for color-line delimited boundaries
#
class Sqed::BoundaryFinder::ColorLineFinder < Sqed::BoundaryFinder

  attr_accessor :boundary_color

  def initialize(**opts)
    # image: image, layout: layout, boundary_color: :green, use_thumbnail: true)
    image = opts[:image]
    layout = opts[:layout]
    use_thumbnail = opts[:use_thumbnail]
    @boundary_color = opts[:boundary_color] || :green

    super(image: image, layout: layout, use_thumbnail: use_thumbnail)

    raise 'No layout provided.' if @layout.nil?
    @boundary_color = boundary_color

    if use_thumbnail
      @original_image = @image.copy
      @image = thumbnail
    end
    find_bands
  end

  private

  def find_bands
    case layout    # boundaries.coordinates are referenced from stage image

      # No specs for this yet
    when :seven_slot
      top_bottom_split = Sqed::BoundaryFinder.color_boundary_finder(image: image, scan: :columns, boundary_color: boundary_color)              # detect vertical division [array]
      left_right_split = Sqed::BoundaryFinder.color_boundary_finder(image: image, sample_subdivision_size: 2, boundary_color: boundary_color)  # detect horizontal division [array]

      boundaries.set(0, [0, 0, left_right_split[0], top_bottom_split[0]])
      boundaries.set(6, [0, top_bottom_split[2], left_right_split[0], image.rows - top_bottom_split[2]] )

      right_top_image = image.crop( left_right_split[2], 0, image.columns - left_right_split[2], top_bottom_split[0] , true) # sections 1,2
      right_bottom_image = image.crop(left_right_split[2], top_bottom_split[2], image.columns - left_right_split[2], image.rows - top_bottom_split[2], true)  # sections 3,4,5

      right_top_split = corrected_frequency(Sqed::BoundaryFinder.color_boundary_finder(image: right_top_image, boundary_color: boundary_color)) # vertical line b/w 1 & 2, use "corrected_frequency" to account for color bleed from previous crop

      boundaries.set(1, [left_right_split[2], 0, right_top_split[0], top_bottom_split[0] ])
      boundaries.set(2, [left_right_split[2] + right_top_split[2], 0, right_top_image.columns - right_top_split[2], top_bottom_split[0]])

      right_bottom_split = corrected_frequency(Sqed::BoundaryFinder.color_boundary_finder(image: right_bottom_image, scan: :columns, sample_subdivision_size: 2, boundary_color: boundary_color)) # horizontal line b/w (5,3) & 4, use "corrected_frequency" to account for color bleed from previous crop

      bottom_right_top_image = right_bottom_image.crop(0,0, image.columns - left_right_split[2], right_bottom_split[0], true) # 3,5

      boundaries.set(3, [ left_right_split[2] + right_top_split[2], top_bottom_split[2], left_right_split[2] + right_top_split[2], bottom_right_top_image.rows ])
      boundaries.set(5, [ left_right_split[2], top_bottom_split[2], right_top_split[0], bottom_right_top_image.rows])

      # ! not high enough
      boundaries.set(4, [left_right_split[2], top_bottom_split[2] + right_bottom_split[2], image.columns - left_right_split[2], right_bottom_image.rows ])

    when :vertical_split 
      t = Sqed::BoundaryFinder.color_boundary_finder(image: image, boundary_color: boundary_color)  #detect vertical division
      return if t.nil?
      boundaries.set(0, [0, 0, t[0], image.rows])  # left section of image
      boundaries.set(1, [t[2], 0, image.columns - t[2], image.rows])  # right section of image

    when :horizontal_split
      t = Sqed::BoundaryFinder.color_boundary_finder(image: image, scan: :columns, boundary_color: boundary_color)  # set to detect horizontal division
      return if t.nil?

      boundaries.set(0, [0, 0, image.columns, t[0]])  # upper section of image
      boundaries.set(1, [0, t[2], image.columns, image.rows - t[2]])  # lower section of image

    when :right_t # only 3 zones expected, with horizontal division in right-side of vertical division
      vertical = self.class.new(image: @image, layout: :vertical_split, boundary_color: boundary_color, use_thumbnail: false ).boundaries

      irt = image.crop(*vertical.for(1), true)
      right = self.class.new(image: irt, layout: :horizontal_split, boundary_color: boundary_color, use_thumbnail: false ).boundaries

      boundaries.set(0, vertical.for(0))    
      boundaries.set(1, [ vertical.x_for(1), 0, right.width_for(0), right.height_for(0) ] ) 
      boundaries.set(2, [ vertical.x_for(1), right.y_for(1), right.width_for(1), right.height_for(1)] )  

    when :vertical_offset_cross   # 4 zones expected, with (varying) horizontal division in left- and right- sides of vertical division
      vertical = self.class.new(image: @image, layout: :vertical_split, boundary_color: boundary_color, use_thumbnail: false).boundaries

      ilt = image.crop(*vertical.for(0), true) 
      irt = image.crop(*vertical.for(1), true)

      left = self.class.new(image: ilt, layout: :horizontal_split, boundary_color: boundary_color, use_thumbnail: false).boundaries   # fails
      right = self.class.new(image: irt, layout: :horizontal_split, boundary_color: boundary_color, use_thumbnail: false ).boundaries # OK

      boundaries.set(0, [0, 0, left.width_for(0), left.height_for(0) ]) 
      boundaries.set(1, [vertical.x_for(1), 0, right.width_for(0), right.height_for(0) ]) 
      boundaries.set(2, [vertical.x_for(1), right.y_for(1), right.width_for(1), right.height_for(1) ]) 
      boundaries.set(3, [0, left.y_for(1), left.width_for(1), left.height_for(1) ]) 

      # No specs for this yet
    when :horizontal_offset_cross
      horizontal = self.class.new(image: @image, layout: :horizontal_split, boundary_color: boundary_color, use_thumbnail: false ).boundaries

      itop = image.crop(*horizontal.for(0), true) 
      ibottom = image.crop(*horizontal.for(1), true)

      top = self.class.new(image: ilt, layout: :vertical_split, boundary_color: boundary_color, use_thumbnail: false ).boundaries
      bottom = self.class.new(image: irt, layout: :vertical_split, boundary_color: boundary_color, use_thumbnail: false ).boundaries

      boundaries.set(0, [0, 0, top.width_for(0), top.height_for(0) ]) 
      boundaries.set(1, [top.x_for(1), 0, top.width_for(1), top.height_for(1) ]) 
      boundaries.set(2, [bottom.x_for(1), horizontal.y_for(1), bottom.width_for(1), bottom.height_for(1) ]) 
      boundaries.set(3, [0, horizontal.y_for(1), bottom.width_for(0), bottom.height_for(0) ]) 

    when :cross # 4 zones, with perfectly intersected horizontal and vertical division
      v = self.class.new(image: @image, layout: :vertical_split, boundary_color: boundary_color, use_thumbnail: false ).boundaries
      h = self.class.new(image: @image, layout: :horizontal_split, boundary_color: boundary_color, use_thumbnail: false).boundaries 

      return if v.nil? || h.nil?

      boundaries.set(0, [0,0, v.width_for(0), h.height_for(0) ]) 
      boundaries.set(1, [ v.x_for(1), 0, v.width_for(1), h.height_for(0) ]) 
      boundaries.set(2, [ v.x_for(1), h.y_for(1), v.width_for(1), h.height_for(1) ]) 
      boundaries.set(3, [0, h.y_for(1), v.width_for(0), h.height_for(1) ]) 

    else # no @layout provided !?

      boundaries.set(0, [0, 0, image.columns, image.rows])   # totality of image as default
    end

    boundaries.complete = true if boundaries.populated?

    if use_thumbnail
      @image = @original_image
      zoom_boundaries
      @original_image = nil
    end

  end
end
