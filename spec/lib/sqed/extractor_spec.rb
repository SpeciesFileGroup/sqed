require 'spec_helper'
describe Sqed::Extractor do

  let(:metadata_map) { 
    {0 => :annotated_specimen, 1 => :identifiers, 2 => :image_registration, 3 => :identifiers }
  } 
 
  let(:image) { ImageHelpers.standard_cross_green }

  let(:boundaries) { 
    Sqed::BoundaryFinder::CrossFinder.new(
      image: image
      ).boundaries
  }

  let(:e) {Sqed::Extractor.new(
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
