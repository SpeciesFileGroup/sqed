require 'spec_helper'

describe Sqed::Boundaries do

  let(:s) { Sqed::Boundaries.new } 
  let(:layout) {:horizontal_split}

  specify "#coordinates defaults to a Hash when no layout provided" do
    expect(s.coordinates).to eq({})
  end

  context 'with a layout provided' do
    before {
      s.layout = layout
    }

    specify "coordinates can be initialized after the fact (bad idea likely)" do
      expect(s.initialize_coordinates).to be_truthy
    end

    specify "#coordinates has one coordinate system for each section (key in layout)" do
      s.initialize_coordinates
      expect(s.coordinates.keys.sort).to eq([0,1])
    end

    specify "#each" do
      s.initialize_coordinates
      s.each do |k,v|
        expect([0,1].include?(k)).to be(true) 
        expect(v).to eq([nil, nil, nil, nil])
      end
    end
  end

  context '#offset' do
    let(:s) { Sqed.new(target_image: ImageHelpers.crossy_green_line_specimen, target_pattern: :vertical_offset_cross) }
    let(:offset_boundaries) { 
      s.crop_image
      s.boundaries.offset(s.stage_boundary) 
    }

    specify "offset and size should match internal found areas " do
      sbx = s.stage_boundary.x_for(0)
      sby = s.stage_boundary.y_for(0)

      total_sections =  s.boundaries.coordinates.count
      expect(offset_boundaries.complete).to be(true)

      (0..total_sections - 1).each do |i|
        # check all the x/y      
        expect(offset_boundaries.x_for(i)).to eq(s.boundaries.x_for(i) + sbx)
        expect(offset_boundaries.y_for(i)).to eq(s.boundaries.y_for(i) + sby)

        # check all width/heights
        expect(offset_boundaries.width_for(i)).to eq(s.boundaries.width_for(i))
        expect(offset_boundaries.height_for(i)).to eq(s.boundaries.height_for(i))
      end
    end
  end
end 
