require 'spec_helper'

describe 'handling 7 slot stages' do

  let(:image) { ImageHelpers.inhs_stage_7_slot }
  let(:sqed) { Sqed.new(target_image: image, target_pattern: :seven_slot, boundary_color: :red, has_border: false ) }

  context 'parses' do
    specify 'new() without errors' do
      expect( sqed ).to be_truthy
    end

    specify 'get result without errors' do
      expect( sqed.result ).to be_truthy
    end
  end

  context 'without target_pattern' do
    let(:m) { {"0" => "collecting_event_labels", "1" => "determination_labels", "2" => "other_labels", "3" => "image_registration", "4" => "curator_metadata", "5" => "identifier", "6" => "specimen" } }
    let(:s) { Sqed.new(target_image: image, metadata_map: m, target_layout: :seven_slot, boundary_color: :red, has_border: false ) }

    specify 'get result without errors' do
      expect( sqed.result ).to be_truthy
    end
  end

end 
