require 'spec_helper'

describe Sqed::BoundaryFinder::GreenLineFinder do
  # let(:image) { ImageHelpers.standard_cross_green }
  let(:image) { ImageHelpers.four_green_lined_quadrants }
  # image = ImageHelpers.standard_cross_green
  let(:b) {
    # let(:image) { ImageHelpers.standard_cross_green }
    # Sqed::BoundaryFinder::GreenLineFinder.new(image: image)
    Sqed::BoundaryFinder::StageFinder.new(image: image)    #, layout: SqedConfig::LAYOUTS::offset_cross
  }
  let(:c) {
    b.boundaries
  }
  let(:d) {image.crop(c.coordinates[0][0],c.coordinates[0][1],c.coordinates[0][2],c.coordinates[0][3])}
  # let(:d) {
  #   image.crop(126,86,756,596)
  # }
  # d = image.crop(126,86,756,596)
  let(:e) {
    Sqed::BoundaryFinder::GreenLineFinder.new(image: d)
  }
# e = Sqed::BoundaryFinder::GreenLineFinder.new(image: d)
  let(:f) {
    e.boundaries
  }
 # f = e.boundaries

  specify '#boundaries returns a Sqed::Boundaries instance' do
    expect(image).to be_truthy
    expect(b).to be_truthy
    expect(c).to be_truthy
    expect(d).to be_truthy
    expect(e).to be_truthy
    expect(f).to be_truthy
    expect(b.boundaries.class).to eq(Sqed::Boundaries)
    expect(f.boundaries.class).to eq(Sqed::Boundaries)
  end

  # @jrflood - here is an example of dynamically specify tests for a range of values
  # TODO: all these tests are currently failing becuase the finder is setting corners[] not setting values in the boundaries method (see comments in model) 
  context 'width and height of a standard cross for the test image should be equal for all' do
    # 0, 1, 2, 3, not 0,1,2,3,4 (= 5 things)
    (0..3).each do |i|
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
