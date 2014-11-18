require 'spec_helper'

describe Sqed::BoundaryFinder::GreenLineFinder do
  let(:image) { ImageHelpers.standard_cross_green }
  let(:b) { 
    Sqed::BoundaryFinder::GreenLineFinder.new(image: image) 
  }
  let(:c) {b.boundaries}

  specify '#boundaries returns a Sqed::Boundaries instance' do
    expect(b.boundaries.class).to eq(Sqed::Boundaries)
  end

  # @jrflood - here is an example of dynamically specify tests for a range of values
  context 'width and height of a stanard cross for the test image should be equal for all' do
    (0..4).each do |i|
      specify "the #{i}th image has width < 504" do
        expect(c.width_for(i)).to be < 504 
      end

      specify "the #{i}th image has width < 504" do
        expect(c.height_for(i)).to be < 400
      end
    end
  end

  specify 'the 0th image starts at x = 0' do
    expect(c.x_for(0)).to eq(0)
  end

  specify 'the 0th image starts at y = 0' do
    expect(c.y_for(0)).to eq(0)
  end

  specify 'the 1th image starts at y = 0' do
    expect(c.y_for(0)).to eq(0)
  end

end 
