require 'spec_helper'

describe 'handling T stage images' do

  let(:image) { ImageHelpers.left_t_stage }
  let(:sqed) do
    Sqed.new(
      image: image,
      pattern: :left_t,
      boundary_color: :red,
      has_border: false )
  end

  let(:m) do
    { 0 => 'annotated_specimen',
      1 => 'identifier',
      2 => 'image_registration'
    }
  end

  context 'simple boundaries - without thumbnail' do
    let(:s) { Sqed.new(
      image: image, metadata_map: m, use_thumbnail: false,
      layout: :left_t, 
      boundary_finder: Sqed::BoundaryFinder::ColorLineFinder,
      boundary_color: :red,
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
      pattern: :left_t,
      boundary_color: :red,
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
