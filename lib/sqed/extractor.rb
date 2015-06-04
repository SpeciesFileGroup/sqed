require 'RMagick'

# An Extractor takes Boundries object and a metadata_map pattern and returns a Sqed::Result
# 
class Sqed::Extractor

  # a Sqed::Boundaries instance 
  attr_accessor :boundaries

  # a metadata_map hash from EXTRACTION_PATTERNS like:
  #   {0 => :annotated_specimen, 1 => :identifiers, 2 =>:image_registration }
  attr_accessor :metadata_map

  # a Magick::Image file
  attr_accessor :image

  def initialize(boundaries: boundaries, metadata_map: metadata_map, image: image)
    raise 'boundaries not provided or provided boundary is not a Sqed::Boundaries' if boundaries.nil? || !boundaries.class == Sqed::Boundaries
    raise 'metadata_map not provided or metadata_map not a Hash' if metadata_map.nil? || !metadata_map.class == Hash
    raise 'image not provided' if image.nil? || !image.class == Magick::Image

    @metadata_map = metadata_map
    @boundaries = boundaries
    @image = image
  end

  def result
    r = Sqed::Result.new()
  
    # assign the images to the result
    boundaries.each do |section, coords|
      r.send("#{SqedConfig::LAYOUT_SECTION_TYPES[section]}=", extract_image(coords))
    end 

    # assign the metadata to the result
    metadata_map.keys.each do |section_index, section_type|
      # only extract data if a parser exists
      if parser = SqedConfig::SECTION_PARSERS[section_type]
        r.send("#{section_type}=", parser.new(image: r.send(section_type + "_image").text) )
      end
    end

    r
  end

  # coords are x1, y1, x2, y2
  def extract_image(coords)
    # crop takes x, y, width, height
    # @image.crop(coords[0], coords[1], coords[2] - coords[0], coords[3] - coords[1] )
    bp = 0
    @image.crop(coords[0], coords[1], coords[2], coords[3], true)
  end

end
