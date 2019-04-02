require 'spec_helper'

describe 'handling 7 slot stages' do

  let(:image) { ImageHelpers.horizontal_offset_cross_red }
  let(:sqed) do
    Sqed.new(
      image: image,
      pattern: :horizontal_offset_cross,
      boundary_color: :red,
      has_border: false )
  end

  let(:m) do
    { 0 => 'curator_metadata',
      1 => 'identifier',
      2 => 'image_registration',
      3 => 'annotated_specimen'
    }
  end

  context 'parses' do
    specify 'new() without errors' do
      expect(sqed).to be_truthy
    end

    specify 'get result without errors' do
      expect(sqed.result).to be_truthy
    end
  end

  context 'simple boundaries - without thumbnail' do
    let(:s) { Sqed.new(image: image, metadata_map: m, use_thumbnail: false, layout: :horizontal_offset_cross, boundary_color: :red, has_border: false ) }

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

  context 'boundaries - with_thumbnail' do
    let(:s) { Sqed.new(image: ImageHelpers.horizontal_offset_cross_red, use_thumbnail: true, pattern: :horizontal_offset_cross, boundary_color: :red, has_border: false ) }

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
