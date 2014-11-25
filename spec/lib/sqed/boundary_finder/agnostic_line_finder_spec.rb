require 'spec_helper'

describe Sqed::BoundaryFinder::AgnosticLineFinder do  # describe 'Find a barrier line' do    # it 'should scan a stage image and find dividing lines' do

  let(:image) { ImageHelpers.four_green_lined_quadrants }

  let(:b) {


    Sqed::BoundaryFinder::StageFinder.new(image: image) #, layout: SqedConfig::LAYOUTS::offset_cross
  }
  let(:c) {
    b.boundaries
  }
# let(:d) { image.crop(c.coordinates[0][0], c.coordinates[0][1], c.coordinates[0][2], c.coordinates[0][3], true) }
  let(:d) { image.crop(*c.for(0), true) }

  let(:e) {
    Sqed::BoundaryFinder::AgnosticLineFinder.new(image: d, layout: :right_t)
  }

  let(:f) {
  e.boundaries
  }

  let(:g) {
    Sqed::BoundaryFinder::AgnosticLineFinder.new(image: d, layout: :offset_cross)
  }

  let(:h) {
    g.boundaries
  }
  specify 'initial image columns are as expected for :image above' do
    expect(image.columns).to eq(3264)
    expect(image.rows).to eq(2452)
  #
    expect(b.boundaries.x_for(0)).to eq(484)
    expect(b.boundaries.y_for(0)).to eq(361)
    expect(b.boundaries.width_for(0)).to eq(2447)
    expect(b.boundaries.height_for(0)).to eq(1890)
  #
    expect(d.columns).to eq(2447)
    expect(d.rows).to eq(1890)
  end

  # specify 'image cropped to stage boundary is correct size ' do
    specify "CrossGreenLinesSpecimen using right_t layout should yield 3 rectangular boundaries" do
    # write out the found quadrants
    q = nil
    (f.first[0]..f.count - 1).each do |j|
      q = d.crop(*f.for(j), true)
      q.write("q0#{j}.jpg")
    end
    expect(q.columns).to eq(413)   # for quadrant 2
    expect(q.rows).to eq(910)       # for quadrant 2
  end

  specify "CrossGreenLinesSpecimen using offset_cross layout should yield 4 rectangular boundaries" do
    # write out the found quadrants
    q = nil
    (h.first[0]..h.count - 1).each do |j|
      q = d.crop(*h.for(j), true)
      q.write("q1#{j}.jpg")
    end
    expect(q.columns).to eq(1953)   # for quadrant 3
    expect(q.rows).to eq(847)       # for quadrant 3
  end

end