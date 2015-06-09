require 'rmagick'

# An Extractor takes Boundries object and a metadata_map pattern and returns a Sqed::Result
# 
class Sqed::Extractor

  # a Sqed::Boundaries instance 
  attr_accessor :boundaries

  # a metadata_map hash from EXTRACTION_PATTERNS like:
  #   {0 => :annotated_specimen, 1 => :identifier, 2 =>:image_registration }
  attr_accessor :metadata_map

  # a Magick::Image file
  attr_accessor :image

  def initialize(boundaries: boundaries, metadata_map: metadata_map, image: image)
    raise 'boundaries not provided or provided boundary is not a Sqed::Boundaries' if boundaries.nil? || !boundaries.class == Sqed::Boundaries
    raise 'metadata_map not provided or metadata_map not a Hash' if metadata_map.nil? || !metadata_map.class == Hash
    raise 'image not provided' if image.nil? || !image.class.name == 'Magick::Image'

    @metadata_map = metadata_map
    @boundaries = boundaries
    @image = image
  end

  def result
    r = Sqed::Result.new()

    # assign the images to the result
    boundaries.each do |section_index, coords|
      image_setter = "#{metadata_map[section_index]}_image="
      r.send(image_setter, extract_image(coords))
    end 

    # assign the metadata to the result
    metadata_map.each do |section_index, section_type|
      # only extract data if a parser exists
      if parsers = SqedConfig::SECTION_PARSERS[section_type]

        section_image = r.send("#{section_type}_image")
        updated = r.send(section_type)

        parsers.each do |p|
          parsed_result = p.new(section_image).text
          updated.merge!(p::TYPE => parsed_result) if parsed_result
        end

        r.send("#{section_type}=", updated) 
      end
    end

    r
  end

  # crop takes x, y, width, height
  def extract_image(coords)
    i = @image.crop(*coords, true)
  end

end
