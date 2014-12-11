require 'spec_helper'

#  Reference boundaries to original image, which is cropped to the stage, preserving the offset x,y
describe Sqed::BoundaryFinder::ColorLineFinder do  # describe 'Find a barrier line' do    # it 'should scan a stage image and find dividing lines' do

  # let(:image) { ImageHelpers.black_stage_green_line_specimen }   # ***********************************
  let(:image) { ImageHelpers.crossy_green_line_specimen }

  let(:b) {
    # Sqed::CropImage.new(image: :image)

    Sqed::BoundaryFinder::StageFinder.new(image: image) #, layout: SqedConfig::LAYOUTS::offset_cross
  }
  let(:c) {
    b.boundaries
  }
let(:d) { image.crop(c.coordinates[0][0], c.coordinates[0][1], c.coordinates[0][2], c.coordinates[0][3], true) }
  # let(:d) { Sqed::CropImage.new(image: :image) }

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
    ah.crop(*ch.for(0), true)   # ************** reverse these for
    # ah.crop(100, 100, 777, 555, true)   # since StageFinder fails on this synthetic image
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

    # expect(b.stage_boundary).to eq(b.boundaries.coordinates[0])
    # expect(b.stage_boundary[0]).to eq(b.boundaries.coordinates[0][0])
    # expect(b.stage_boundary[1]).to eq(b.boundaries.coordinates[0][1])

    expect(c.x_for(0)).to be_within(0.02*407).of(407)  #).to be(true)
    expect(c.y_for(0)).to be_within(0.02*301).of(301)  #, 0.02, 301)).to be(true)
    expect(c.width_for(0)).to be_within(0.02*2587).of(2587)  #, 0.02, 2587)).to be(true)
    expect(c.height_for(0)).to be_within(0.02*1990).of(1990)  #, 0.02, 1990)).to be(true)

    expect(d.columns).to be_within(2587/50).of(2587)
    expect(d.rows).to be_within(1990/50).of(1990)
  end

# specify 'image cropped to stage boundary is correct size ' do
  specify "CrossGreenLinesSpecimen using right_t layout should yield 3 rectangular boundaries" do
    # write out the found quadrants
    # use the f object for right_t
    q = nil
    (f.first[0]..f.count - 1).each do |j|
      q = d.crop(*f.for(j), true)
      q.write("tmp/q0#{j}.jpg")
    end
    expect(f.count).to eq(3)

    expect(f.x_for(0)).to be_within(1).of(1)
    expect(f.y_for(0)).to be_within(1).of(1)
    expect(f.width_for(0)).to be_within(0.02*2051).of(2051)
    expect(f.height_for(0)).to be_within(0.02*1990).of(1990)

    expect(f.x_for(1)).to be_within(0.02*2099).of(2099)
    expect(f.y_for(1)).to be_within(1).of(1)
    expect(f.width_for(1)).to be_within(0.02*438).of(488)
    expect(f.height_for(1)).to be_within(0.02*987).of(987)

    expect(f.x_for(2)).to be_within(0.02*2099).of(2099)
    expect(f.y_for(2)).to be_within(0.02*1026).of(1026)
    expect(f.width_for(2)).to be_within(0.02*488).of(488)
    expect(f.height_for(2)).to be_within(0.02*964).of(964)

  end

  specify "CrossGreenLinesSpecimen using offset_cross layout should yield 4 rectangular boundaries" do
    # write out the found quadrants
    q = nil
    (h.first[0]..h.count - 1).each do |j|
      q = d.crop(*h.for(j), true)
      q.write("tmp/q1#{j}.jpg")
    end
    expect(h.count).to eq(4)

    expect(h.x_for(0)).to be_within(0.02*2099).of(0)
    expect(h.y_for(0)).to be_within(0.02*0).of(0)#, 0.02, 0)).to be(true)
    expect(h.width_for(0)).to be_within(0.02*2051).of(2051)#, 0.02, 2003)).to be(true)
    expect(h.height_for(0)).to be_within(0.02*1054).of(1054)#, 0.02, 1015)).to be(true)

    expect(h.x_for(1)).to be_within(0.02*2099).of(2099)#, 0.02, 2047)).to be(true)
    expect(h.y_for(1)).to be_within(0.02*0).of(0)#, 0.02, 0)).to be(true)
    expect(h.width_for(1)).to be_within(0.02*488).of(488)#, 0.02, 438)).to be(true)
    expect(h.height_for(1)).to be_within(0.02*987).of(987)#, 0.02, 948)).to be(true)

    expect(h.x_for(2)).to be_within(0.02*2099).of(2099)#, 0.02, 2047)).to be(true)
    expect(h.y_for(2)).to be_within(0.02*1026).of(1026)#, 0.02, 989)).to be(true)
    expect(h.width_for(2)).to be_within(0.02*488).of(488)#, 0.02, 438)).to be(true)
    expect(h.height_for(2)).to be_within(0.02*964).of(964)#, 0.02, 923)).to be(true)

    expect(h.x_for(3)).to be_within(0.02*0).of(0)#, 0.02, 0)).to be(true)
    expect(h.y_for(3)).to be_within(0.02*1093).of(1093)#, 0.02, 1054)).to be(true)
    expect(h.width_for(3)).to be_within(0.02*2051).of(2051)#, 0.02, 2003)).to be(true)
    expect(h.height_for(3)).to be_within(0.02*897).of(897)#, 0.02, 858)).to be(true)

  end

  specify "CrossGreenLinesSpecimen using vertical_split layout should yield 2 rectangular boundaries" do
    # write out the found quadrants
    q = nil
    hv.each do |k, v|
      q = d.crop(*v, true)
      q.write("tmp/q2#{k}.jpg")
    end
    expect(hv.count).to eq(2)

    pct = 0.02

    expect(hv.x_for(0)).to be_within(0).of(0)
    expect(hv.y_for(0)).to be_within(0).of(0)
    expect(hv.width_for(0)).to be_within(pct*2051).of(2051)
    expect(hv.height_for(0)).to be_within(pct*1990).of(1990)

    expect(hv.x_for(1)).to be_within(pct*2099).of(2099)
    expect(hv.y_for(1)).to be_within(pct*0).of(0)
    expect(hv.width_for(1)).to be_within(pct*488).of(488)
    expect(hv.height_for(1)).to be_within(pct*1990).of(1990)
  end


  specify "boundary_offset_cross_red using horizontal_split layout should yield 2 rectangular boundaries" do
    # write out the found quadrants  #boundaries revised 10DEC2014
    q = nil
    hh.each do |k, v|
      q = dh.crop(*v, true)
      q.write("tmp/q3#{k}.jpg")
    end

    expect(hh.count).to eq(2)
    expect([[0, 0, 798, 146] , [0, 0, 799, 145]]).to include(hh.coordinates[0])      # for quadrant 0
    expect(hh.coordinates[0]).to eq([0, 0, 799, 145]).or eq([0, 0, 798, 146])      # for quadrant 0
    expect(hh.coordinates[1]).to eq([0, 154, 799, 445])   # for quadrant 1
  end


  specify "offset cross method on black stage specimen should yield 4 rectangular boundaries for 0" do

    q = nil
    (hbs.first[0]..hbs.count - 1).each do |j|
      q = dbs.crop(*hbs.for(j), true)
      q.write("tmp/qb#{j}.jpg")
    end
    expect(hbs.coordinates.keys.count).to eq(4)

    expect(hbs.width_for(0)).to be_within(0.02*2999).of(2999)#, 0.02, 2903)).to be(true)
    expect(hbs.height_for(0)).to be_within(0.02*506).of(506)#, 0.02, 462)).to be(true)

  end

  specify "offset cross method on black stage specimen should yield 4 rectangular boundaries for 1" do
    expect(hbs.width_for(1)).to be_within(0.02*447).of(447)#, 0.02, 378)).to be(true)
    expect(hbs.height_for(1)).to be_within(0.02*487).of(487)#, 0.02, 441)).to be(true)
  end

  specify "offset cross method on black stage specimen should yield 4 rectangular boundaries for 2" do
    expect(hbs.width_for(2)).to be_within(0.02*447).of(447)#, 0.02, 378)).to be(true)
    expect(hbs.height_for(2)).to be_within(0.02*1680).of(1680)#, 0.02, 1635)).to be(true)
  end

  specify "offset cross method on black stage specimen should yield 4 rectangular boundaries for 3" do
    expect(hbs.width_for(3)).to be_within(0.02*2999).of(2999)#, 0.02, 2934)).to be(true)
    expect(hbs.height_for(3)).to be_within(0.02*1677).of(1677)#, 0.02, 1634)).to be(true)
  end

end
