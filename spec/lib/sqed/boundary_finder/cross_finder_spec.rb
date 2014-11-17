require 'spec_helper'

describe Sqed::BoundaryFinder::CrossFinder do
  let(:image) { ImageHelpers.of_size() }
  let(:b) {Sqed::BoundaryFinder::CrossFinder.new(image: image)}

  specify '#boundaries returns a Sqed::Boundaries instance' do
    expect(b.boundaries.class).to eq Sqed::Boundaries
  end


end 
