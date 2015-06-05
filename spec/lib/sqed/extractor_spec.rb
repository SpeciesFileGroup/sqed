require 'spec_helper'
describe Sqed::Extractor do

  let(:metadata_map) { 
    {0 => :specimen, 1 => :identifier, 2 => :nothing, 3 => :image_registration }
  } 
 
  let(:image) { ImageHelpers.crossy_green_line_specimen }

  let(:boundaries) { 
    Sqed::BoundaryFinder::CrossFinder.new(
      image: image
    ).boundaries
  }

  let(:e) {
    Sqed::Extractor.new(
      boundaries: boundaries,
      image: image,
      metadata_map: metadata_map
    )
  }

  context 'attributes' do
    specify '#image' do
      expect(e).to respond_to(:image)
    end

    specify '#metadata_map' do
      expect(e).to respond_to(:metadata_map)
    end
 
    specify '#boundaries' do
      expect(e).to respond_to(:boundaries)
    end
  end

  specify '#result retuns a Sqed::Result' do
    expect(e.result.class.name).to eq('Sqed::Result')
  end


end 


