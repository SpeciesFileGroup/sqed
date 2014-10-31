# encoding: UTF-8

require_relative "sqed/parser"
require_relative "sqed/parser/ocr_parser"
require_relative "sqed/parser/barcode_parser"

require_relative "sqed/boundaries"
require_relative "sqed/boundary_finder"
require_relative "sqed/boundary_finder/green_line_finder"
require_relative "sqed/boundary_finder/cross_finder"
require_relative "sqed/boundary_finder/stage_finder"

# Sqed constants, including patterns for extraction etc.
#
module SqedConfig

  # Layouts refer to the arrangement of the divided stage.
  # Windows are enumerated from the top left, moving around the border 
  # in a clockwise position.  For example:
  #    0  | 1
  #   ----|----  :equal_cross
  #    3  | 2
  #  
  #       | 1
  #    0  |----  :right_t
  #       | 2
  #
  #        0
  #    --------  :horizontal_split
  #        1
  #
  #        |
  #      0 | 1  :vertical_split
  #        |
  #
  #   -----
  #   | 0 |  :internal_box
  #   -----
  #
  # Hahs values are used to stub out 
  # the Sqed::Boundaries instance.
  #
  LAYOUTS = {
   cross: [0,1,2,3],
   offset_cross: [0,1,2,3],
   horizontal_split: [0,1] ,
   vertical_split: [0.1] ,
   right_t: [0,1,2],
   left_t: [0,1,2],
   internal_box: [0]
  }

  #  Each element of the layout is a "section".  
  LAYOUT_SECTION_TYPES = [
    :stage,                 # the image contains the full stage 
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
      boundary_finder: Sqed::BoundaryFinder::GreenLineFinder,
      layout: :right_t, 
      metadata_map: {0 => :annotated_specimen, 1 => :identifiers, 2 =>:image_registration }
    },
    standard_cross: {
      boundary_finder: Sqed::BoundaryFinder::CrossFinder,
      layout: :cross, 
      metadata_map: {0 => :labels, 1 => :specimen, 2 => :identifier, 3 => :specimen_deteriminations }
    },
    stage: {
      boundary_finder: Sqed::BoundaryFinder::StageFinder,
      layout: :internal_box, 
      metadata_map: {0 => :stage}
    }
    # etc. ...
  }

  DEFAULT_TMP_DIR = "/tmp"

end
