require 'spec_helper'

describe Sqed::BoundaryFinder::ColorLineFinder do  # describe 'Find a barrier line' do    # it 'should scan a stage image and find dividing lines' do

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
    Sqed::BoundaryFinder::ColorLineFinder.new(image: d, layout: :right_t)
  }

  let(:f) {
  e.boundaries
  }

  let(:g) {
    Sqed::BoundaryFinder::ColorLineFinder.new(image: d, layout: :offset_cross)
  }

  let(:h) {
    g.boundaries
  }

  let(:gv) {
    Sqed::BoundaryFinder::ColorLineFinder.new(image: d, layout: :vertical_split)
  }

  let(:hv) {
    gv.boundaries
  }

  let(:ah) {
    ImageHelpers.offset_cross_red
  }

  let(:bh) {
    Sqed::BoundaryFinder::StageFinder.new(image: ah)
  }
  let(:ch) {
    bh.boundaries
  }
  let(:dh) {
    # ah.crop(*ch.for(0), true)
    ah.crop(100, 100, 777, 555, true)   # since StageFinder fails on this synthetic image
  }
  let(:gh) {
    Sqed::BoundaryFinder::ColorLineFinder.new(image: dh, layout: :horizontal_split, boundary_color: :red)
  }

  let(:hh) {
    gh.boundaries
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
    expect(f.count).to eq(3)
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
    expect(h.count).to eq(4)
    expect(q.columns).to eq(1953)   # for quadrant 3
    expect(q.rows).to eq(847)       # for quadrant 3
  end

  specify "CrossGreenLinesSpecimen using vertical_split layout should yield 2 rectangular boundaries" do
    # write out the found quadrants
    q = nil
    (hv.first[0]..hv.count - 1).each do |j|
      q = d.crop(*hv.for(j), true)
      q.write("q2#{j}.jpg")
    end
    expect(hv.count).to eq(2)
    expect(q.columns).to eq(413)   # for quadrant 1
    expect(q.rows).to eq(1890)       # for quadrant 1
  end

  specify "boundary_offset_cross_red using horizontal_split layout should yield 2 rectangular boundaries" do
    # write out the found quadrants
    q = nil
    (hh.first[0]..hh.count - 1).each do |j|
      q = dh.crop(*hh.for(j), true)
      q.write("q3#{j}.jpg")
    end
    expect(hh.count).to eq(2)
    expect(hh.coordinates[0]).to eq([0, 0, 777, 136])      # for quadrant 0
    expect(hh.coordinates[1]).to eq([0, 147, 777, 408])   # for quadrant 1
  end

end
