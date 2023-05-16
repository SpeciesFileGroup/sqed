require 'rmagick'

class Sqed

  # An Extractor takes Boundaries object and a metadata_map and returns a Sqed::Result
  #
  # Extract assumes a successful preprocessing (e.g. finding boundaries, cropping images)!
  #
  # Only Tesseract based raises errors should be occurring at this point.
  #
  class Extractor

    class Error < StandardError; end;

    # a Sqed::Boundaries instance
    attr_accessor :boundaries

    # @return [Hash] like `{0 => :annotated_specimen, 1 => :identifier, 2 => :image_registration }`
    # a metadata_map hash from EXTRACTION_PATTERNS like:
    attr_accessor :metadata_map

    # @return [Magick::Image file]
    attr_accessor :image

    def initialize(**opts)
      @metadata_map = opts[:metadata_map]
      @boundaries = opts[:boundaries]
      @image = opts[:image]

      # TODO: `.extractable?` catches the nil? case
      raise Sqed::Error, 'boundaries not provided or provided boundary is not a Sqed::Boundaries' if boundaries.nil? || !boundaries.kind_of?(Sqed::Boundaries)
      raise Sqed::Error, 'metadata_map not provided or metadata_map not a Hash' if metadata_map.nil? || !metadata_map.kind_of?(Hash)
      raise Sqed::Error, 'image not provided' if image.nil? || !image.kind_of?(Magick::Image)
    end

    def result
      r = Sqed::Result.new

      r.sections = metadata_map.keys.sort.collect{|k| metadata_map[k]}

      # assign the images to the result
      boundaries.each do |section_index, coords|
        section_type = metadata_map[section_index]

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
            parsed_result = p.new(section_image).get_text(section_type: section_type)
            updated[p::TYPE] = parsed_result if parsed_result && parsed_result.length > 0
          end

          r.send("#{section_type}=", updated)
        end
      end

      r
    end

    # crop takes x, y, width, height
    def extract_image(coords)
      @image.crop(*coords, true)
    end

  end
end
