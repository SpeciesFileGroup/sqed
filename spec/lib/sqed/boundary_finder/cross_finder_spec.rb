require 'spec_helper'

describe Sqed::BoundaryFinder::CrossFinder do
  let(:image) { ImageHelpers.of_size(800, 600) }
  let(:b) {Sqed::BoundaryFinder::CrossFinder.new(target_image: image)}
  let(:c) {b.boundaries}

  specify '#boundaries returns a Sqed::Boundaries instance' do
    expect(b.boundaries.class).to eq(Sqed::Boundaries)
  end

  specify 'the 0th image starts at x = 0' do
    expect(c.x_for(0)).to eq(0)
  end

  specify 'the 0th image starts at y = 0' do
    expect(c.y_for(0)).to eq(0)
  end

  specify 'the 0th image has width = 400' do
    expect(c.width_for(0)).to eq(400)
  end

  specify 'the 0th image has height = 300' do
    pct = 0.02
    expect(c.height_for(0)).to be_within(pct*300).of(300)
  end

end 
