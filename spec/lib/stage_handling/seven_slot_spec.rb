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
    { 0 => :collecting_event_labels,
      1 => :determination_labels,
      2 => :other_labels,
      3 => :image_registration,
      4 => :curator_metadata,
      5 => :identifier,
      6 => :specimen }
  end


  let(:w) {22.5} # 1/2 width red "tape"

  let(:coords) {
    {
      0 => [
        0,
        0,
        1674,
        1280
      ],
      1 => [
        1820,
        0,
        1773,
        1280
      ],
      2 => [
        3746,
        0,
        1726,
        1280
      ],
      3 => [
        3746,
        1422,
        3746,
        836
      ],
      4 => [
        1820,
        2382,
        3652,
        2226
      ],
      5 => [
        1820,
        1422,
        1773,
        836
      ],
      6 => [
        0,
        1422,
        1674,
        2226
      ]
    }
  }

  context 'parses' do
    specify 'new() without errors' do
      expect(sqed).to be_truthy
    end

    specify 'get result without errors' do
      expect(sqed.result).to be_truthy
    end
  end

  context 'trickier boundaries - without thumbnail' do
    # perfect parsing currently
    let(:s) { Sqed.new(
      image: ImageHelpers.inhs_stage_7_slot2,
      layout: :seven_slot, # layout + metadata map + boundary_finder signature
      metadata_map: m,
      boundary_finder: Sqed::BoundaryFinder::ColorLineFinder,
      use_thumbnail: false,
      boundary_color: :red,
      has_border: false ) }

    specify 'boundaries are reasonable' do
      s.result
      c = s.boundaries.coordinates

      c.each do |section, values|
        c[section].each_with_index do |v, i|
          min = coords[section][i] - w
          max = coords[section][i] + w
          msg = "section #{section}, index #{i}, '#{v}' is out of range #{min}-#{max} "
          expect((v > min) && (v < max)).to be_truthy, msg
        end
      end
    end
  end

  # image size is a failure here
  context 'trickier boundaries - with_thumbnail' do
    let(:s) { Sqed.new(
      image: ImageHelpers.inhs_stage_7_slot2,
      use_thumbnail: true,
      pattern: :seven_slot, # pattern signature
      boundary_color: :red, has_border: false ) }

    xspecify 'boundaries are reasonable' do
      s.result
      c = s.boundaries.coordinates
      errors = []

      c.each do |section, values|
        c[section].each_with_index do |v, i|
          min = coords[section][i] - w
          max = coords[section][i] + w

          msg = "section #{section}, index #{i}, '#{v}' is #{(v - coords[section][i]).abs } out of range #{min}-#{max}"
          if !((v > min) && (v < max))
            errors.push msg
          else
            errors.push "section #{section} (#{v}) is OK"
          end
        end
      end
      expect(errors).to be_empty, errors.join("\n")
    end
  end

  context 'another image' do
    let(:s) { Sqed.new(image: ImageHelpers.frost_seven_slot, use_thumbnail: true, pattern: :seven_slot, boundary_color: :red, has_border: false ) }

    specify '#result' do
      expect(s.result).to be_truthy
    end
  end

end
