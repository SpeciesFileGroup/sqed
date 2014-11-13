
# An Extractor takes Boundries object and a layout pattern and returns a Sqed::Result
# 
class Sqed::Extractor

  attr_accessor :boundaries, :layout, :image

  def initialize(boundaries: boundaries, layout: layout, image: image)
    raise if boundaries.nil? || !boundaries.class == Sqed::Boundaries
    raise if layout.nil? || !layout.class == Hash

    @layout = layout
    @boundaries = boundaries
    @image = image
  end

  def result
    r = Sqed::Result.new()
   
    # assign the images to the result
    boundaries.each do |section, coords|
      r.send("#{LAYOUT_SECTION_TYPES[section]}=", extract_image(coords))
    end 

    # assign the metadata to the result
    layout.keys.each do |section_index, section_type|
      # only extract data if a parser exists
      if parser = SECTION_PARSERS[section_type]
        r.send("#{section_type}=", parser.new(image: r.send(section_type + "_image").text) )
      end
    end

    r
  end

  # coords are x1, y1, x2, y2
  def extract_image(coords)
    # crop takes x, y, width, height
    @image.crop(coords[0], coords[1], coords[2] - coords[0], coords[3] - coords[1] )
  end

end
