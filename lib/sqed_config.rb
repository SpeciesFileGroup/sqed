# encoding: UTF-8

require 'zxing'

require_relative "sqed/parser"
require_relative "sqed/parser/ocr_parser"
require_relative "sqed/parser/barcode_parser"

require_relative "sqed/boundaries"
require_relative "sqed/boundary_finder"
require_relative "sqed/boundary_finder/cross_finder"
require_relative "sqed/boundary_finder/stage_finder"
require_relative "sqed/boundary_finder/color_line_finder"

# Sqed constants, including patterns for extraction etc.
#
module SqedConfig

  # Layouts refer to the arrangement of the divided stage.
  # Windows are enumerated from the top left, moving around the border 
  # in a clockwise position.  For example:
  #
  #    0  | 1
  #   ----|----  :equal_cross (always perfectly divided through the center)
  #    3  | 2
  #  
  #
  #    0  | 1
  #   ----|----  :cross (height of [0, 1], [2,3] same, width of [0,1], [2,3] same, otherwise variable (i.e. height(0) != height(3))
  #       | 
  #    3  | 2
  # 
  #    0  |  1
  #       |
  #   ---------  :horizontal_offset_cross // NOT CURRENTLY IMPLEMENTED
  #    3   | 2
  #
  #
  #    0  |  1
  #       |____
  #   ----|      :vertical_offset_cross // matches current code !! 
  #    3  |  2
  #
  #       | 1
  #    0  |----  :right_t
  #       | 2
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

  # Hash values are used to stub out
  # the Sqed::Boundaries instance.
  # TODO: deprecate for simpler breakdown (cross, split, t)
  LAYOUTS = {
    cross: [0,1,2,3],
    vertical_offset_cross: [0,1,2,3], 
    horizontal_split: [0,1],
    vertical_split: [0,1],
    right_t: [0,1,2],
    left_t: [0,1,2],
    internal_box: [0]
  }

  # Each element of the layout is a "section".  
  LAYOUT_SECTION_TYPES = [
    :stage,                 # the image contains the full stage 
    :specimen,              # the specimen only, no metadata should be present
    :annotated_specimen,    # a specimen is present, and metadata is too
    :determination_labels,  # the section contains text that determines the specimen
    :labels,                # the section contains collecting event and non-determination labels
    :identifier,            # the section contains an identifier (e.g. barcode or unique number)
    :image_registration,    # the section contains only image registration information,
    :curator_metadata,      # the section contains text with curator metadata
    :nothing                # section is empty 
  ] 

  # Links section types to data parsers
  SECTION_PARSERS = {
    labels: [ Sqed::Parser::OcrParser ],
    identifier: [ Sqed::Parser::BarcodeParser, Sqed::Parser::OcrParser ],
    deterimination_labels: [ Sqed::Parser::OcrParser ],
    curator_metadata: [  Sqed::Parser::OcrParser ],
    specimen: [ Sqed::Parser::OcrParser ],
  }

  EXTRACTION_PATTERNS = {
    right_t: {
      boundary_finder: Sqed::BoundaryFinder::ColorLineFinder,
      layout: :right_t,
      metadata_map: {0 => :annotated_specimen, 1 => :identifier, 2 =>:image_registration }
    },
    vertical_offset_cross: {
      boundary_finder: Sqed::BoundaryFinder::ColorLineFinder,
      layout: :vertical_offset_cross,
      metadata_map: {0 => :curator_metadata, 1 => :identifier, 2 => :image_registration, 3 => :specimen }
     # metadata_map: {0 => :annotated_specimen, 1 => :identifier, 2 =>:image_registration }
    },
    standard_cross: {
      boundary_finder: Sqed::BoundaryFinder::CrossFinder,
      layout: :cross, 
      metadata_map: {0 => :labels, 1 => :specimen, 2 => :identifier, 3 => :specimen_determinations }
    },
    stage: {
      boundary_finder: Sqed::BoundaryFinder::StageFinder,
      layout: :internal_box, 
      metadata_map: {0 => :stage}
    }
    # etc. ...
  }

  DEFAULT_TMP_DIR = "/tmp"

  def self.index_for_section_type(pattern, section_type)
    EXTRACTION_PATTERNS[pattern][:metadata_map].invert[section_type]
  end
end
