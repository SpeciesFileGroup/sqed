require 'rmagick'

# An Extractor takes Boundries object and a metadata_map and returns a Sqed::Result
# 
class Sqed::Extractor

  class Error < StandardError; end;

  # a Sqed::Boundaries instance 
  attr_accessor :boundaries

  # a metadata_map hash from EXTRACTION_PATTERNS like:
  #   {0 => :annotated_specimen, 1 => :identifier, 2 =>:image_registration }
  attr_accessor :metadata_map

  # a Magick::Image file
  attr_accessor :image

  def initialize(target_boundaries: boundaries, target_metadata_map: metadata_map, target_image: image)
    raise Error, 'boundaries not provided or provided boundary is not a Sqed::Boundaries' if target_boundaries.nil? || !target_boundaries.class == Sqed::Boundaries
    raise Error, 'metadata_map not provided or metadata_map not a Hash' if target_metadata_map.nil? || !target_metadata_map.class == Hash
    raise Error, 'image not provided' if target_image.nil? || !target_image.class.name == 'Magick::Image'

    @metadata_map = target_metadata_map
    @boundaries = target_boundaries
    @image = target_image
  end

  def result
    r = Sqed::Result.new()

    r.sections = metadata_map.values.sort
      
    # assign the images to the result
    boundaries.each do |section_index, coords|
      section_type = metadata_map[section_index]
     
      # TODO: raise this higher up the chain 
      raise Error, "invalid section_type [#{section_type}]" if !SqedConfig::LAYOUT_SECTION_TYPES.include?(section_type)

      r.send("#{section_type}_image=", extract_image(coords))
      r.boundary_coordinates[section_type] = coords
    end 

    # assign the metadata to the result
    metadata_map.each do |section_index, section_type|
      # only extract data if a parser exists
      if parsers = SqedConfig::SECTION_PARSERS[section_type]

        section_image = r.send("#{section_type}_image")

        updated = r.send(section_type)

        parsers.each do |p|
          parsed_result = p.new(section_image).text(section_type: section_type)
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
