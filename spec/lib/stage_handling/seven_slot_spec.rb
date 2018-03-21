require 'spec_helper'

describe 'handling 7 slot stages' do

  let(:image) { ImageHelpers.inhs_stage_7_slot }
  let(:sqed) do
    Sqed.new(
        image: image,
        pattern: :seven_slot,
        boundary_color: :red,
        has_border: false )
  end

  let(:m) do
    { 0 => 'collecting_event_labels',
      1 => 'determination_labels',
      2 => 'other_labels',
      3 => 'image_registration',
      4 => 'curator_metadata',
      5 => 'identifier',
      6 => 'specimen' }
  end

  context 'parses' do
    specify 'new() without errors' do
      expect(sqed).to be_truthy
    end

    specify 'get result without errors' do
      expect(sqed.result).to be_truthy
    end
  end

  context 'without pattern' do
    let(:s) { Sqed.new(image: image, metadata_map: m, pattern: :seven_slot, boundary_color: :red, has_border: false ) }
    specify 'get result without errors' do
      expect(sqed.result).to be_truthy
    end
  end

  context 'trickier boundaries' do
    let(:s) { Sqed.new(image: ImageHelpers.inhs_stage_7_slot2, metadata_map: m, pattern: :seven_slot, boundary_color: :red, has_border: false ) }

    specify 'get result without errors' do
      expect(s.result).to be_truthy
    end

    specify 'boundaries are reasonable' do
      s.result
      c = s.boundaries.coordinates 
      c.each do |section, values|
        c[section].each_with_index do |v, i|
          msg = "section #{section}, index #{i} has a bad value '#{v}'"
          expect(v > -1).to be_truthy, msg
        end
      end
    end
  end

end 
