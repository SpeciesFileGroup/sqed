# require 'zxing'

require_relative 'sqed_utils'

require_relative 'sqed/parser'
require_relative 'sqed/parser/ocr_parser'
require_relative 'sqed/parser/barcode_parser'

require_relative 'sqed/boundaries'
require_relative 'sqed/boundary_finder'
require_relative 'sqed/boundary_finder/cross_finder'
require_relative 'sqed/boundary_finder/stage_finder'
require_relative 'sqed/boundary_finder/color_line_finder'

# Sqed constants, including patterns for extraction etc.
#
module SqedConfig

  # Layouts refer to the arrangement of the divided stage.
  # Windows are enumerated from the top left, moving around the border
  # in a clockwise position.  For example:
  #
  #    0  | 1
  #   ----|----  :cross (any cross pattern)
  #       |
  #    3  | 2
  #
  #
  #    0  |  1
  #       |
  #   ---------  :horizontal_offset_cross
  #    3    | 2
  #
  #
  #        0
  #    --------  :horizontal_split
  #        1
  #
  #
  #    0 | 1 | 2
  #   ------------
  #      | 5 |      :lep_stage
  #    6 |---- 3
  #      | 4 |
  #
  #
  #    0 | 1 |  2
  #   --------------
  #          | 5 |    :lep_stage2
  #      6   |---- 3
  #          | 4 |
  #
  #  #
  #    0 | 1 | 2
  #   ------------
  #      | 5 | 3    :seven_slot
  #    6 |--------
  #      |   4
  #
  #
  #    0  |  1
  #       |____
  #   ----|      :vertical_offset_cross
  #    3  |  2
  #
  #
  #      |
  #    0 | 1  :vertical_split
  #      |
  #
  #    -------
  #    |-----|
  #    || 0 ||  :internal_box
  #    |-----|
  #    -------
  #
  #     0     :t
  #   -----
  #   2 | 1
  #
  #
  #   0 | 1   :inverted_t
  #   -----
  #     2
  #
  #    0 |
  #   ---| 1   : left_t
  #    2 |
  #
  #      | 1
  #    0 |---  :right_t
  #      | 2
  #
  #    -----
  #    | 0 |  :stage
  #    -----
  #
  # Hash values are used to stub out
  # the Sqed::Boundaries instance.
  LAYOUTS = {
    t: [0,1,2],
    inverted_t: [0, 1, 2],
    right_t: [0, 1, 2],
    left_t: [0, 1, 2],
    cross: [0, 1, 2, 3],
    horizontal_offset_cross: [0, 1, 2, 3],
    horizontal_split: [0, 1],
    lep_stage: [0, 1, 2, 3, 4, 5, 6],
    lep_stage2: [0, 1, 2, 3, 4, 5, 6],
    seven_slot: [0, 1, 2, 3, 4, 5, 6],
    vertical_offset_cross: [0, 1, 2, 3],
    vertical_split: [0, 1],
    internal_box: [0],
    stage: [0]
  }.freeze

  # Each element of the layout is a "section".
  LAYOUT_SECTION_TYPES = [
    :annotated_specimen,      # a specimen is present, and metadata is too
    :collecting_event_labels, # the section that contains collecting event labels (only)
    :curator_metadata,        # the section contains text with curator metadata
    :determination_labels,    # the section contains text that determines the specimen (only)
    :identifier,              # the section contains an identifier (e.g. barcode or unique number)
    :image_registration,      # the section contains only image registration information,
    :labels,                  # the section contains collecting event and other non-determination labels
    :nothing,                 # section is empty
    :other_labels,            # the section that contains text that misc.
    :specimen,                # the specimen only, no metadata should be present
    :stage,                   # the image contains the full stage
  ].freeze

  # Links section types to data parsers
  SECTION_PARSERS = {
    annotated_specimen: [Sqed::Parser::OcrParser],
    collecting_event_labels: [Sqed::Parser::OcrParser],
    curator_metadata: [Sqed::Parser::OcrParser],
    determination_labels: [Sqed::Parser::OcrParser],
    identifier: [Sqed::Parser::OcrParser, Sqed::Parser::BarcodeParser],
    image_registration: [],
    labels: [Sqed::Parser::OcrParser],
    nothing: [],
    other_labels: [Sqed::Parser::OcrParser],
    specimen: [],
    stage: []
  }.freeze

  EXTRACTION_PATTERNS = {
    t: {
      boundary_finder: Sqed::BoundaryFinder::ColorLineFinder,
      layout: :t,
      metadata_map: { 0 => :annotated_specimen, 1 => :identifier, 2 => :image_registration }
    },

    inverted_t: {
      boundary_finder: Sqed::BoundaryFinder::ColorLineFinder,
      layout: :inverted_t,
      metadata_map: { 0 => :identifier, 1 => :image_registration, 2 => :annotated_specimen }
    },

    cross: {
      boundary_finder: Sqed::BoundaryFinder::ColorLineFinder,
      layout: :cross,
      metadata_map: { 0 => :curator_metadata, 1 => :identifier, 2 => :image_registration, 3 => :annotated_specimen }
    },

    horizontal_split: {
      boundary_finder: Sqed::BoundaryFinder::ColorLineFinder,
      layout: :horizontal_split,
      metadata_map: { 0 => :annotated_specimen, 1 => :identifier }
    },

    horizontal_offset_cross: {
      boundary_finder: Sqed::BoundaryFinder::ColorLineFinder,
      layout: :horizontal_offset_cross,
      metadata_map: { 0 => :curator_metadata, 1 => :identifier, 2 => :image_registration, 3 => :annotated_specimen }
    },

    lep_stage: {
      boundary_finder: Sqed::BoundaryFinder::ColorLineFinder,
      layout: :lep_stage,
      metadata_map: { 0 => :curator_metadata, 1 => :collecting_event_labels, 2 => :image_registration, 3 => :identifier, 4 => :other_labels, 5 => :determination_labels, 6 => :specimen }
    },

    lep_stage2: {
      boundary_finder: Sqed::BoundaryFinder::ColorLineFinder,
      layout: :lep_stage2,
      metadata_map: { 0 => :curator_metadata, 1 => :collecting_event_labels, 2 => :image_registration, 3 => :identifier, 4 => :other_labels, 5 => :determination_labels, 6 => :specimen }
    },

    left_t: {
      boundary_finder: Sqed::BoundaryFinder::ColorLineFinder,
      layout: :left_t,
      metadata_map: { 0 => :annotated_specimen, 1 => :identifier, 2 => :image_registration }
    },

    right_t: {
      boundary_finder: Sqed::BoundaryFinder::ColorLineFinder,
      layout: :right_t,
      metadata_map: { 0 => :annotated_specimen, 1 => :identifier, 2 => :image_registration }
    },

    stage: {
      boundary_finder: Sqed::BoundaryFinder::StageFinder,
      layout: :internal_box,
      metadata_map: { 0 => :stage }
    },

    seven_slot: {
      boundary_finder: Sqed::BoundaryFinder::ColorLineFinder,
      layout: :seven_slot,
      metadata_map: { 0 => :collecting_event_labels, 1 => :determination_labels, 2 => :other_labels, 3 => :image_registration, 4 => :curator_metadata, 5 => :identifier, 6 => :specimen }
    },

    vertical_offset_cross: {
      boundary_finder: Sqed::BoundaryFinder::ColorLineFinder,
      layout: :vertical_offset_cross,
      metadata_map: { 0 => :curator_metadata, 1 => :identifier, 2 => :image_registration, 3 => :annotated_specimen }
    },

    vertical_split: {
      boundary_finder: Sqed::BoundaryFinder::ColorLineFinder,
      layout: :vertical_split,
      metadata_map: { 0 => :annotated_specimen, 1 => :identifier }
    }
  }.freeze

  BOUNDARY_COLORS = [:red, :green, :blue, :black].freeze

  DEFAULT_TMP_DIR = '/tmp'.freeze

  def self.index_for_section_type(pattern, section_type)
    EXTRACTION_PATTERNS[pattern][:metadata_map].invert[section_type]
  end

  # Format to return JSON that is externaly exposed
  def self.metadata
    return {
      boundary_colors: BOUNDARY_COLORS,
      extraction_patterns: EXTRACTION_PATTERNS.select{|k,v| k != :stage},
      section_parsers: SECTION_PARSERS,
      layout_section_types: LAYOUT_SECTION_TYPES,
      layouts: LAYOUTS.select{|k,v| k != :internal_box }
    }
  end
end
