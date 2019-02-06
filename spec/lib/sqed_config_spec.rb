require 'spec_helper'

describe SqedConfig do

  specify '.metadata' do
    expect(SqedConfig.metadata.keys).to contain_exactly(:boundary_colors, :extraction_patterns, :section_parsers, :layout_section_types, :layouts)
  end

end
