require 'spec_helper'

describe Sqed::BoundaryFinder::ColorLineFinder do  # describe 'Find a barrier line' do    # it 'should scan a stage image and find dividing lines' do

  # let(:image) { ImageHelpers.black_stage_green_line_specimen }   # ***********************************
  let(:image) { ImageHelpers.crossy_green_line_specimen }

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
    # ah.crop(*ch.for(0), true)   # ************** reverse these for
    ah.crop(100, 100, 777, 555, true)   # since StageFinder fails on this synthetic image
  }
  let(:gh) {
    Sqed::BoundaryFinder::ColorLineFinder.new(image: dh, layout: :horizontal_split, boundary_color: :red)
  }

  let(:hh) {
    gh.boundaries
  }
  let(:ibs) { ImageHelpers.black_stage_green_line_specimen }   # ***********************************
# let(:bi) { ImageHelpers.crossy_green_line_specimen }

  let(:bbs) {

    Sqed::BoundaryFinder::StageFinder.new(image: ibs) #, layout: SqedConfig::LAYOUTS::offset_cross
  }
  let(:cbs) {
    bbs.boundaries
  }
# let(:bd) { image.crop(c.coordinates[0][0], c.coordinates[0][1], c.coordinates[0][2], c.coordinates[0][3], true) }
  let(:dbs) { ibs.crop(*cbs.for(0), true) }

  # let(:ebs) {
  #   Sqed::BoundaryFinder::ColorLineFinder.new(image: dbs, layout: :offset_cross)
  # }
  #
  # let(:fbs) {
  #   ebs.boundaries
  # }

  let(:gbs) {
    Sqed::BoundaryFinder::ColorLineFinder.new(image: dbs, layout: :offset_cross)
  }

  let(:hbs) {
    gbs.boundaries
  }


  specify 'initial image columns are as expected for :image above' do
    expect(image.columns).to eq(3264)
    expect(image.rows).to eq(2452)
  #
    expect(b.boundaries.x_for(0)).to be > 484 * 0.98
    expect(b.boundaries.x_for(0)).to be < 484 * 1.02
    expect(b.boundaries.y_for(0)).to be > 361 * 0.98
    expect(b.boundaries.y_for(0)).to be < 361 * 1.02
    expect(b.boundaries.width_for(0)).to be > 2447 * 0.98
    expect(b.boundaries.width_for(0)).to be < 2447 * 1.02
    expect(b.boundaries.height_for(0)).to be > 1890 * 0.98
    expect(b.boundaries.height_for(0)).to be < 1890 * 1.02
  #
    expect(d.columns).to be > 2447 * 0.97
    expect(d.columns).to be < 2447 * 1.02
    expect(d.rows).to be > 1890 * 0.97
    expect(d.rows).to be < 1890 * 1.02
  end

  # specify 'image cropped to stage boundary is correct size ' do
    specify "CrossGreenLinesSpecimen using right_t layout should yield 3 rectangular boundaries" do
    # write out the found quadrants
      # use the f object for right_t
    q = nil
    (f.first[0]..f.count - 1).each do |j|
      q = d.crop(*f.for(j), true)
      # q.write("q0#{j}.jpg")
    end
    expect(f.count).to eq(3)
    expect(q.columns).to  be > 413 * 0.98   # for quadrant 2
    expect(q.columns).to  be < 413 * 1.02   # for quadrant 2
    expect(q.rows).to be > 910 * 0.97       # for quadrant 2
    expect(q.rows).to be < 910 * 1.02       # for quadrant 2
  end

  specify "CrossGreenLinesSpecimen using offset_cross layout should yield 4 rectangular boundaries" do
    # write out the found quadrants
    q = nil
    (h.first[0]..h.count - 1).each do |j|
      q = d.crop(*h.for(j), true)
      # q.write("q1#{j}.jpg")
    end
    expect(h.count).to eq(4)
    # expect(q.columns).to eq(1953)   # for quadrant 3
    # expect(q.rows).to eq(847)       # for quadrant 3
    expect(q.columns).to be > 1953 * 0.98   # for quadrant 3
    expect(q.columns).to be < 1953 * 1.02   # for quadrant 3
    expect(q.columns).to be < 1953 * 1.02   # for quadrant 3
    expect(q.columns).to be_within(1953/50).of 1953   # for quadrant 3 -- 2%
    expect(in_range(q.columns, 0.02, 1953))  # for quadrant 3 -- 2%
    expect(in_range(q.columns, 0.02, 1953)).to be true  # for quadrant 3 -- 2%
    expect(q.rows).to be > 847 * 0.97       # for quadrant 3
    expect(q.rows).to be < 847 * 1.02       # for quadrant 3
  end

  specify "CrossGreenLinesSpecimen using vertical_split layout should yield 2 rectangular boundaries" do
    # write out the found quadrants
    q = nil
    (hv.first[0]..hv.count - 1).each do |j|
      q = d.crop(*hv.for(j), true)
      # q.write("q2#{j}.jpg")
    end
    expect(hv.count).to eq(2)
    # expect(q.columns).to eq(413)   # for quadrant 1
    # expect(q.rows).to eq(1890)       # for quadrant 1
    expect(q.columns).to  be > 413 * 0.98   # for quadrant 1
    expect(q.columns).to  be < 413 * 1.02   # for quadrant 1
    expect(q.rows).to be > 1890 * 0.97       # for quadrant 1
    expect(q.rows).to be < 1890 * 1.02       # for quadrant 1
  end

  specify "boundary_offset_cross_red using horizontal_split layout should yield 2 rectangular boundaries" do
    # write out the found quadrants
    q = nil
    (hh.first[0]..hh.count - 1).each do |j|
      q = dh.crop(*hh.for(j), true)
      # q.write("q3#{j}.jpg")
    end
    expect(hh.count).to eq(2)
    expect([[0, 0, 777, 136] , [0, 0, 777, 138]]).to include(hh.coordinates[0])      # for quadrant 0
    expect(hh.coordinates[0]).to eq([0, 0, 777, 136]).or eq([0, 0, 777, 138])      # for quadrant 0
    # expect(hh.coordinates[0]).to include([[0, 0, 777, 136] , [0, 0, 777, 138]])      # for quadrant 0
    # expect(hh.coordinates[0]).to eq([0, 0, 777, 136] | [0, 0, 777, 138])      # for quadrant 0
    expect(hh.coordinates[1]).to eq([0, 147, 777, 408])   # for quadrant 1
  end

  specify "offset cross method on black stage specimen should yield 4 rectangular boundaries" do
    expect(hbs.count).to eq(4)
    expect(hbs.coordinates[0]). to eq([0, 0, 2870, 425])
    expect(hbs.coordinates[1]). to eq([2995, 0, 306, 355])
    expect(hbs.coordinates[2]). to eq([2995, 547, 306, 1593])
    expect(hbs.coordinates[3]). to eq([0, 551, 2870, 1589])
    q = nil
    (hbs.first[0]..hbs.count - 1).each do |j|
      q = dbs.crop(*hbs.for(j), true)
      # q.write("qb#{j}.jpg")
    end
  end
end

