require 'spec_helper'

describe Sqed::BoundaryFinder::CrossFinder do
  let(:image) { ImageHelpers.of_size() }
  let(:b) {Sqed::BoundaryFinder::CrossFinder.new(image: image)}

  context 'attributes' do
    specify '#is_border' do
      expect(b).to respond_to(:is_border)
    end
  end

  context 'with a stanandard cross' do

    specify '#boundaries returns a Sqed::Boundaries instance' do
      expect(b.boundaries.class).to eq Sqed::Boundaries
    end
  end


end 
