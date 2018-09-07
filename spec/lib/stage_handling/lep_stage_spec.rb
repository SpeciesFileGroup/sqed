require 'spec_helper'

describe 'handling lep stage images' do

  let(:image) { ImageHelpers.lep_stage }
  let(:sqed) do
    Sqed.new(
      image: image,
      pattern: :lep_stage,
      boundary_color: :red,
      has_border: false )
  end

  let(:m) do
    { 0 => :curator_metadata,
      1 => :collecting_event_labels,
      2 => :image_registration,
      3 => :identifier,
      4 => :other_labels,
      5 => :determination_labels,
      6 => :specimen 
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

  context 'trickier boundaries - without thumbnail' do
    let(:s) { Sqed.new(image: ImageHelpers.lep_stage, use_thumbnail: false, pattern: :lep_stage, boundary_color: :red, has_border: false ) }

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

  context 'trickier boundaries - with_thumbnail' do
    let(:s) { Sqed.new(image: ImageHelpers.lep_stage, use_thumbnail: true, pattern: :lep_stage, boundary_color: :red, has_border: false ) }

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
