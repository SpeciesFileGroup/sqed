require 'spec_helper'

describe 'handling stage images' do

  let(:image) { ImageHelpers.stage }
  let(:sqed) do
    Sqed.new(
      image: image,
      pattern: :stage,
      has_border: false )
  end

  let(:m) do
    { 0 => 'stage' }
  end

  context 'simple boundaries - without thumbnail' do
    let(:s) { Sqed.new(
      image: image, metadata_map: m, use_thumbnail: false,
      layout: :stage, 
      boundary_finder: Sqed::BoundaryFinder::ColorLineFinder,
      has_border: false ) }

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
    let(:s) { Sqed.new(
      image: image,
      use_thumbnail: true,
      pattern: :stage,
      has_border: false ) }

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
