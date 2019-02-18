require 'spec_helper'

describe SqedConfig do

  specify '.metadata' do
    expect(SqedConfig.metadata.keys).to contain_exactly(:boundary_colors, :extraction_patterns, :section_parsers, :layout_section_types, :layouts)
  end

  specify 'layouts' do
    expect(SqedConfig.metadata[:layouts].keys).to contain_exactly(:cross, :horizontal_offset_cross, :horizontal_split, :lep_stage, :right_t, :seven_slot, :vertical_offset_cross, :vertical_split)
  end

  specify 'layouts are in patterns' do
    expect(SqedConfig.metadata[:layouts].keys + [:stage]).to contain_exactly(*SqedConfig::EXTRACTION_PATTERNS.keys) 
  end



end
