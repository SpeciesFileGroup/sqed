require 'spec_helper'

describe 'handling inverted T stage images' do

  let(:image) { ImageHelpers.inverted_t_stage }
  let(:sqed) do
    Sqed.new(
      image: image,
      pattern: :inverted_t,
      boundary_color: :red,
      has_border: false )
  end

  let(:m) do
    { 0 => 'identifier',
      1 => 'image_registration',
      2 => 'annotated_specimen',
    }
  end

  context 'simple boundaries - without thumbnail' do
    let(:s) { Sqed.new(
      image: image, metadata_map: m, use_thumbnail: false,
      layout: :inverted_t,
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
      pattern: :inverted_t,
      boundary_color: :red,
      has_border: false ) }

    specify 'boundaries are reasonable' do
      s.result
      # s.result.write_images
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
