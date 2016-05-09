require 'spec_helper'

describe 'handling 7 slot stages' do

  let(:image) { ImageHelpers.inhs_stage_7_slot }
  let(:sqed) { Sqed.new(target_image: image, target_pattern: :seven_slot, boundary_color: :red, has_border: false ) }

  context 'parses' do
    specify 'new() without errors' do
      expect( sqed ).to be_truthy
    end

    specify 'get_result without errors' do
      expect( sqed.result ).to be_truthy
    end
  end

end 
