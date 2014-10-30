# encoding: UTF-8

recent_ruby = RUBY_VERSION >= '2.1.1'
raise "IMPORTANT: sqed gem requires ruby >= 2.1.1" unless recent_ruby

require "RMagick"

require_relative "sqed/extractor"
require_relative "sqed/result"

require_relative "sqed/parser"
require_relative "sqed/parser/ocr_parser"
require_relative "sqed/parser/barcode_parser"

require_relative "sqed/boundaries"
require_relative "sqed/boundry_finder"
require_relative "sqed/boundry_finder/green_line_finder"
require_relative "sqed/boundry_finder/cross_finder"
require_relative "sqed/boundry_finder/stage_finder"


# Instants take the following
# 1) A base image @image
# 2) A target extraction pattern
#
# Return a Sqed::Result
#    
#     a = Sqed.new(pattern: :right_t, image: image)
#     b = a.result # => Squed::Result instance
# 
#
# Layouts refer to the arrangement of the divided stage.
# Windows are enumerated from the top left, moving around the border 
# in a clockwise position.  For example:
#    0  | 1
#   ----|----
#    3  | 2
#  
#       | 1
#    0  |----
#       | 2
#
#        0
#    --------
#        1
#
#  Each element of the layout is a "section".  
#  !! All layouts must include an :identifiers section. ?!
#
class Sqed

  LAYOUT_SECTION_TYPES = [
    :specimen,              # the specimen only, no metadata should be present
    :annotated_specimen,    # a specimen is present, and metadata is too
    :determination_labels,  # the section contains text that determines the specimen
    :labels,                # the section contains collecting event and non-determination labels
    :identifier,            # the section contains an identifier (e.g. barcode or unique number)
    :image_registration     # the section contains only image registration information
  ] 

  # Links section types to data parsers
  SECTION_PARSERS = {
    labels: Sqed::OcrParser,
    identifier: Sqed::BarcodeParser,
    deterimination_labels: Sqed::OcrParser
  }


  EXTRACTION_PATTERNS = {
    right_t: { 
      boundry_finder: Sqed::BoundryFinder::GreenLineFinder,
      layout: {0 => :annotated_specimen, 1 => :identifiers, 2 =>:image_registration }
    }
    standard_cross: {
      boundry_finder: Sqed::BoundryFinder::CrossFinder,
      layout: {0 => :labels, 1 => :specimen, 2 => :identifier, 3 => :specimen_deteriminations }
    }
    # etc. ...
  }

  DEFAULT_TMP_DIR = "/tmp"

  attr_accessor :image, :pattern, :stage_image 

  def initialize(image: image, pattern: pattern)
    @image = image
    @pattern = pattern
    @pattern ||= :standard_cross 
  end

  def result
    crop_image
    Sqed::Extractor.new(boundaries: boundaries, layout: EXTRACTION_PATTERNS[@pattern][:layout], image: image).result
  end

  def boundaries
    EXTACTION_PATTERNS[@pattern][:boundry_finder].new(image: @image).boundaries
  end

  def crop_image
    @stage_image = Sqed::ImageExtractor(boundry_finder: :stage_finder, image: @image).img
  end

end
