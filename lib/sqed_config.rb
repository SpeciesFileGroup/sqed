# encoding: UTF-8

require_relative "sqed/parser"
require_relative "sqed/parser/ocr_parser"
require_relative "sqed/parser/barcode_parser"

require_relative "sqed/boundaries"
require_relative "sqed/boundary_finder"
require_relative "sqed/boundary_finder/green_line_finder"
require_relative "sqed/boundary_finder/cross_finder"
require_relative "sqed/boundary_finder/stage_finder"



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
#
#
module SqedConfig
  
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
    labels: Sqed::Parser::OcrParser,
    identifier: Sqed::Parser::BarcodeParser,
    deterimination_labels: Sqed::Parser::OcrParser
  }

  EXTRACTION_PATTERNS = {
    right_t: { 
      boundry_finder: Sqed::BoundaryFinder::GreenLineFinder,
      layout: {0 => :annotated_specimen, 1 => :identifiers, 2 =>:image_registration }
    },
    standard_cross: {
      boundry_finder: Sqed::BoundaryFinder::CrossFinder,
      layout: {0 => :labels, 1 => :specimen, 2 => :identifier, 3 => :specimen_deteriminations }
    }
    # etc. ...
  }

  DEFAULT_TMP_DIR = "/tmp"

end
