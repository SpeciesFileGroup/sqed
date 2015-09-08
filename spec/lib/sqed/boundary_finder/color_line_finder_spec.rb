require 'spec_helper'

describe Sqed::BoundaryFinder::ColorLineFinder do 

  let(:image) { ImageHelpers.crossy_green_line_specimen }

  let(:b) { Sqed::BoundaryFinder::StageFinder.new(image: image) }
  let(:c) {b.boundaries}
  let(:d) { image.crop(*c.for(0), true) }
  
  let(:e) { Sqed::BoundaryFinder::ColorLineFinder.new(image: d, layout: :right_t, use_thumbnail: false) }
  let(:f) { e.boundaries }
  let(:g) { Sqed::BoundaryFinder::ColorLineFinder.new(image: d, layout: :vertical_offset_cross, use_thumbnail: false)}
  let(:h) { g.boundaries }
  let(:gv) { Sqed::BoundaryFinder::ColorLineFinder.new(image: d, layout: :vertical_split, use_thumbnail: false) }
  let(:hv) { gv.boundaries }
 
  let(:ah) { ImageHelpers.vertical_offset_cross_red }
  let(:bh) { Sqed::BoundaryFinder::StageFinder.new(image: ah) }
  let(:ch) { bh.boundaries }
  let(:dh) { ah.crop(*ch.for(0), true) }
  let(:gh) { Sqed::BoundaryFinder::ColorLineFinder.new(image: dh, layout: :horizontal_split, boundary_color: :red, use_thumbnail: false) } # was :horizontal_split
  let(:hh) { gh.boundaries }

  let(:ibs) { ImageHelpers.black_stage_green_line_specimen } 
  let(:bbs) { Sqed::BoundaryFinder::StageFinder.new(image: ibs) } 
  let(:cbs) { bbs.boundaries }
  let(:dbs) { ibs.crop(*cbs.for(0), true) }
  let(:gbs) { Sqed::BoundaryFinder::ColorLineFinder.new(image: dbs, layout: :vertical_offset_cross, use_thumbnail: false) }
  let(:hbs) { gbs.boundaries }

  specify 'initial image columns are as expected for :image above' do
    expect(image.columns).to eq(3264)
    expect(image.rows).to eq(2452)
  end

  context 'stage image is properly found (sanity check, should be tests in stage finder)' do
    specify 'stage image boundaries are correct' do
      pct = 0.02
      expect(in_range(c.x_for(0), pct, 407)).to be(true)
      expect(in_range(c.y_for(0), pct, 301)).to be(true)
      expect(in_range(c.width_for(0), pct, 2587)).to be(true)
      expect(in_range(c.height_for(0), pct, 1990)).to be(true)
    end

    specify 'stage image size is correct' do
      expect(d.columns).to be_within(50).of(2587)
      expect(d.rows).to be_within(40).of(1990)
    end
  end

  specify "CrossGreenLinesSpecimen using right_t layout should yield 3 rectangular boundaries" do
    # use the f object for right_t
    f.each do |i, coord|
      q = d.crop(*coord, true)
      q.write("tmp/q0#{i}.jpg")
    end

    expect(f.count).to eq(3)
    pct = 0.02
    
    expect(f.x_for(0)).to be_within(1).of(1)
    expect(f.y_for(0)).to be_within(1).of(1)
    expect(f.width_for(0)).to be_within(pct*2051).of(2051)
    expect(f.height_for(0)).to be_within(pct*1990).of(1990)

    expect(f.x_for(1)).to be_within(pct*2099).of(2099)
    expect(f.y_for(1)).to be_within(1).of(1)
    expect(f.width_for(1)).to be_within(pct*438).of(488)
    expect(f.height_for(1)).to be_within(pct*987).of(987)

    expect(f.x_for(2)).to be_within(pct*2099).of(2099)
    expect(f.y_for(2)).to be_within(pct*1026).of(1026)
    expect(f.width_for(2)).to be_within(pct*488).of(488)
    expect(f.height_for(2)).to be_within(pct*964).of(964)
  end

  specify "CrossGreenLinesSpecimen using vertical_offset_cross layout should yield 4 rectangular boundaries" do
    h.each do |i, coord|
      q = d.crop(*coord, true)
      q.write("tmp/q1#{i}.jpg")
    end

    expect(h.count).to eq(4)

    pct = 0.02

    expect(h.x_for(0)).to be_within(pct*2099).of(0)
    expect(h.y_for(0)).to be_within(pct*0).of(0)
    expect(h.width_for(0)).to be_within(pct*2051).of(2051)
    expect(h.height_for(0)).to be_within(pct*1054).of(1054)

    expect(h.x_for(1)).to be_within(pct*2099).of(2099)
    expect(h.y_for(1)).to be_within(pct*0).of(0)
    expect(h.width_for(1)).to be_within(pct*488).of(488)
    expect(h.height_for(1)).to be_within(pct*987).of(987)

    expect(h.x_for(2)).to be_within(pct*2099).of(2099)
    expect(h.y_for(2)).to be_within(pct*1026).of(1026)
    expect(h.width_for(2)).to be_within(pct*488).of(488)
    expect(h.height_for(2)).to be_within(pct*964).of(964)

    expect(h.x_for(3)).to be_within(0).of(0)
    expect(h.y_for(3)).to be_within(pct*1093).of(1093)
    expect(h.width_for(3)).to be_within(pct*2051).of(2051)
    expect(h.height_for(3)).to be_within(pct*897).of(897)
  end

  specify "CrossGreenLinesSpecimen using vertical_split layout should yield 2 rectangular boundaries" do
    hv.each do |k, v|
      q = d.crop(*v, true)
      q.write("tmp/q2#{k}.jpg")
    end
    expect(hv.count).to eq(2)

    expect(hv.x_for(0)).to be_within(0.02*0).of(0)
    expect(hv.y_for(0)).to be_within(0.02*0).of(0)
    expect(hv.width_for(0)).to be_within(0.02*2051).of(2051)
    expect(hv.height_for(0)).to be_within(0.02*1990).of(1990)

    expect(hv.x_for(1)).to be_within(0.02*2099).of(2099)
    expect(hv.y_for(1)).to be_within(0.02*0).of(0)
    expect(hv.width_for(1)).to be_within(0.02*488).of(488)
    expect(hv.height_for(1)).to be_within(0.02*1990).of(1990)
  end

  specify "boundary_vertical_offset_cross_red using horizontal_split layout should yield 2 rectangular boundaries" do
    hh.each do |k, v|
      q = dh.crop(*v, true)
      q.write("tmp/q3#{k}.jpg")
    end

    expect(hh.count).to eq(2)
    expect([[0, 0, 798, 146] , [0, 0, 799, 145]]).to include(hh.coordinates[0])    # for quadrant 0
    expect(hh.coordinates[0]).to eq([0, 0, 799, 145]).or eq([0, 0, 798, 146])      # for quadrant 0
    expect(hh.coordinates[1]).to eq([0, 154, 799, 445])                            # for quadrant 1
  end

  specify "offset cross method on black stage specimen should yield 4 rectangular boundaries for 0" do
    (hbs.first[0]..hbs.count - 1).each do |j|
      q = dbs.crop(*hbs.for(j), true)
      q.write("tmp/qb#{j}.jpg")
    end
    expect(hbs.coordinates.keys.count).to eq(4)

    pct = 0.02

    expect(hbs.width_for(0)).to be_within(pct*2999).of(2999)
    expect(hbs.height_for(0)).to be_within(pct*506).of(506)
  end

  specify "offset cross method on black stage specimen should yield 4 rectangular boundaries for 1" do
    expect(hbs.width_for(1)).to be_within(0.02*447).of(447)
    expect(hbs.height_for(1)).to be_within(0.02*487).of(487)
  end

  specify "offset cross method on black stage specimen should yield 4 rectangular boundaries for 2" do
    expect(hbs.width_for(2)).to be_within(0.02*447).of(447)
    expect(hbs.height_for(2)).to be_within(0.02*1680).of(1680)
  end

  specify "offset cross method on black stage specimen should yield 4 rectangular boundaries for 3" do
    expect(hbs.width_for(3)).to be_within(0.02*2999).of(2999)
    expect(hbs.height_for(3)).to be_within(0.02*1677).of(1677)
  end

  context 'thumbnail processing finds reasonable boundaries' do

    let(:thumb) { ImageHelpers.frost_stage_thumb  }
    let(:finder) { Sqed::BoundaryFinder::ColorLineFinder.new(image: thumb, layout: :cross, use_thumbnail: false)}
    let(:finder_boundaries) { finder.boundaries }

    let(:pct)  { 0.08 }

  # before {
  #    finder.boundaries.each do |i, coord|
  #    q = thumb.crop(*coord, true)
  #    q.write("tmp/thumb#{i}.jpg")
  #   end
  # }

    specify "for section 0" do
      expect(finder_boundaries.x_for(0)).to be_within(pct*thumb.columns).of(0)
      expect(finder_boundaries.y_for(0)).to be_within(pct*0).of(0)
      expect(finder_boundaries.width_for(0)).to be_within(pct*66).of(66)
      expect(finder_boundaries.height_for(0)).to be_within(pct*13).of(13)
    end

    specify 'for section 1' do
      expect(finder_boundaries.x_for(1)).to be_within(pct*69).of(69)
      expect(finder_boundaries.y_for(1)).to be_within(pct*0).of(0)
      expect(finder_boundaries.width_for(1)).to be_within(pct*32).of(32)
      expect(finder_boundaries.height_for(1)).to be_within(pct*14).of(14)
    end

    specify 'for section 2' do
      expect(finder_boundaries.x_for(2)).to be_within(pct*69).of(69)
      expect(finder_boundaries.y_for(2)).to be_within(pct*17).of(17)
      expect(finder_boundaries.width_for(2)).to be_within(pct*32).of(32)
      expect(finder_boundaries.height_for(2)).to be_within(pct*59).of(59)
    end

    specify 'for section 3' do
      expect(finder_boundaries.x_for(3)).to be_within(0).of(0)
      expect(finder_boundaries.y_for(3)).to be_within(pct*17).of(17)
      expect(finder_boundaries.width_for(3)).to be_within(pct*65).of(65)
      expect(finder_boundaries.height_for(3)).to be_within(pct*59).of(59)
    end

  end
end
