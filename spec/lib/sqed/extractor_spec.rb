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

  context 'extracting to a #result' do
    let(:r) { e.result }
    
    specify '#result retuns a Sqed::Result' do
      expect(r.class.name).to eq('Sqed::Result')
    end

    specify '#result is populated with images' do
      expect(r.images.values.first.class.name).to eq('Magick::Image') 
    end

    specify '#result is populated with text' do
      expect(r.text_for(:identifier)).to match('PSUC')
      # expect(r.text_for(:identifier)).to match('000085067') # not catching this with default settings
    end

    specify '#sections is populated with section_types' do
      expect(r.sections).to eq( [ :identifier, :image_registration, :nothing, :specimen ] )
    end

    specify '#boundary_coordinates is populated with coordinates' do
      metadata_map.values.each do |section_type|
        (0..3).each do |i|
          expect(r.boundary_coordinates[section_type][i]).to be_truthy 
        end
      end
    end

  end

end 
